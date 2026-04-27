#!/usr/bin/env bash
# Laravel site setup.
#
# Prompts for a project name (or takes it as arguments), derives a slug for the
# project directory, runs the interactive `laravel new` installer so it creates
# the project directory itself, then overlays the Laravel devenv template files
# on top of the fresh app.
#
# Expected environment:
#   TEMPLATE_DIR  Path to the Laravel devenv template source directory.

set -euo pipefail

if [[ -t 2 ]]; then
  red=$'\033[31m'
  bold=$'\033[1m'
  reset=$'\033[0m'
else
  red=""
  bold=""
  reset=""
fi

error() {
  printf '%s\n' "${red}${bold}Error:${reset} $*" >&2
}

die() {
  error "$*"
  exit 1
}

[[ -n "${TEMPLATE_DIR:-}" ]] || die "TEMPLATE_DIR is not set. Run this script through the Nix app so the template path is configured."
[[ -d "$TEMPLATE_DIR" ]] || die "Template directory does not exist: $TEMPLATE_DIR"

project_name=${*:-}

if [[ -z "$project_name" ]]; then
  read -r -p "Project name: " project_name || die "Project name is required."
fi

[[ -n "$project_name" ]] || die "Project name is required."

folder_slug=$(printf '%s' "$project_name" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-//; s/-$//')

site_slug=$(printf '%s' "$project_name" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+//g')

[[ -n "$folder_slug" ]] || die "Unable to derive a project directory from '$project_name'. Use at least one letter or number."
[[ -n "$site_slug" ]] || die "Unable to derive a site slug from '$project_name'. Use at least one letter or number."

target_dir=$folder_slug

[[ ! -e "$target_dir" ]] || die "Target directory already exists: ./$target_dir"

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

site_name_replacement=$(escape_sed_replacement "$project_name")
site_slug_replacement=$(escape_sed_replacement "$site_slug")

app_key="base64:$(openssl rand -base64 32)"
app_key_replacement=$(escape_sed_replacement "$app_key")

# 1. Run the interactive Laravel installer. It creates $target_dir itself.
if ! laravel new "$target_dir"; then
  die "Laravel installer failed. If ./$target_dir was partially created, remove it before trying again."
fi

[[ -d "$target_dir" ]] || die "Laravel installer completed, but the project directory was not created: ./$target_dir"

# 2. Overlay the template files on top of the fresh Laravel app.
if ! rsync -rl "$TEMPLATE_DIR/" "$target_dir/"; then
  die "Failed to copy template files from $TEMPLATE_DIR to ./$target_dir"
fi

[[ -f "$target_dir/devenv.nix" ]] || die "Template copy completed, but ./$target_dir/devenv.nix is missing."

# 3. Fill in the placeholders in devenv.nix.
if ! sed -i \
  -e "s|{{SITE_NAME}}|$site_name_replacement|" \
  -e "s|{{SITE_SLUG}}|$site_slug_replacement|" \
  -e "s|{{APP_KEY}}|$app_key_replacement|" \
  "$target_dir/devenv.nix"; then
  die "Failed to fill placeholders in ./$target_dir/devenv.nix"
fi

cat <<EOF
Created $project_name in ./$target_dir

Next steps:
  cd $target_dir
  devenv up
EOF

#!/usr/bin/env bash
# Create a Laravel project from the bundled template.

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

fail() {
  printf '%s\n' "${red}${bold}Error:${reset} $*" >&2
  exit 1
}

slugify() {
  local separator=$1
  tr '[:upper:]' '[:lower:]' \
    | sed -E "s/[^a-z0-9]+/${separator}/g; s/^${separator}//; s/${separator}$//"
}

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

copy_template() {
  rsync \
    -aL \
    --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
    "$TEMPLATE_DIR/" \
    "$target_dir/"
}

replace_placeholders() {
  local app_key_replacement site_name_replacement site_slug_replacement

  app_key_replacement=$(escape_sed_replacement "$app_key")
  site_name_replacement=$(escape_sed_replacement "$project_name")
  site_slug_replacement=$(escape_sed_replacement "$site_slug")

  sed -i \
    -e "s|{{SITE_NAME}}|$site_name_replacement|" \
    -e "s|{{SITE_SLUG}}|$site_slug_replacement|" \
    -e "s|{{APP_KEY}}|$app_key_replacement|" \
    "$target_dir/devenv.nix"
}

install_dependencies() {
  (
    cd "$target_dir"

    COMPOSER_NO_DEV=0 \
    APP_NAME="$project_name" \
    APP_ENV="${APP_ENV:-local}" \
    APP_LOCALE="${APP_LOCALE:-en}" \
    APP_FALLBACK_LOCALE="${APP_FALLBACK_LOCALE:-en}" \
    APP_KEY="$app_key" \
    CACHE_STORE="${CACHE_STORE:-file}" \
    DB_CONNECTION="${DB_CONNECTION:-sqlite}" \
      composer install --no-interaction --prefer-dist --no-progress

    npm install
  )
}

[[ -n "${TEMPLATE_DIR:-}" ]] || fail "TEMPLATE_DIR is not set. Run this script through the Nix app."
[[ -d "$TEMPLATE_DIR" ]] || fail "Template directory does not exist: $TEMPLATE_DIR"

project_name=${*:-}

if [[ -z "$project_name" ]]; then
  read -r -p "Project name: " project_name || fail "Project name is required."
fi

[[ -n "$project_name" ]] || fail "Project name is required."

folder_slug=$(printf '%s' "$project_name" | slugify '-')
site_slug=$(printf '%s' "$project_name" | slugify '')

[[ -n "$folder_slug" ]] || fail "Unable to derive a project directory from '$project_name'. Use at least one letter or number."
[[ -n "$site_slug" ]] || fail "Unable to derive a site slug from '$project_name'. Use at least one letter or number."

target_dir=$folder_slug
app_key="base64:$(openssl rand -base64 32)"

[[ ! -e "$target_dir" ]] || fail "Target directory already exists: ./$target_dir"

mkdir "$target_dir" || fail "Failed to create project directory: ./$target_dir"
copy_template || fail "Failed to copy template files into ./$target_dir"

[[ -f "$target_dir/devenv.nix" ]] || fail "Template copy completed, but ./$target_dir/devenv.nix is missing."
replace_placeholders || fail "Failed to fill placeholders in ./$target_dir/devenv.nix"

: > "$target_dir/.env" || fail "Failed to create ./$target_dir/.env"
chmod 755 "$target_dir/artisan" || fail "Failed to make ./$target_dir/artisan executable"

for writable_dir in "$target_dir/storage" "$target_dir/bootstrap/cache"; do
  [[ -d "$writable_dir" ]] || continue
  chmod -R u+rwX,go+rX "$writable_dir" || fail "Failed to set permissions on $writable_dir"
done

command -v composer >/dev/null 2>&1 || fail "composer is not on PATH."
command -v npm >/dev/null 2>&1 || fail "npm is not on PATH."
install_dependencies || fail "Failed to install dependencies in ./$target_dir"

cat <<EOF
Created $project_name in ./$target_dir

Next steps:
  cd $target_dir
  devenv up
  php artisan migrate:fresh --seed
EOF

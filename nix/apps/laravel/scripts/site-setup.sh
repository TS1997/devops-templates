#!/usr/bin/env bash
# Create a Laravel project from the bundled template.

set -euo pipefail

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
      composer install --prefer-dist --no-progress

    npm install
  )
}

require_template_dir

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
copy_template "$target_dir" || fail "Failed to copy template files into ./$target_dir"

[[ -f "$target_dir/devenv.nix" ]] || fail "Template copy completed, but ./$target_dir/devenv.nix is missing."
replace_placeholders || fail "Failed to fill placeholders in ./$target_dir/devenv.nix"

: > "$target_dir/.env" || fail "Failed to create ./$target_dir/.env"
chmod 755 "$target_dir/artisan" || fail "Failed to make ./$target_dir/artisan executable"

for writable_dir in "$target_dir/storage" "$target_dir/bootstrap/cache"; do
  [[ -d "$writable_dir" ]] || continue
  chmod -R u+rwX,go+rX "$writable_dir" || fail "Failed to set permissions on $writable_dir"
done

require_command composer
require_command npm
install_dependencies || fail "Failed to install dependencies in ./$target_dir"
git -C "$target_dir" init -b master || fail "Failed to initialize a Git repository in ./$target_dir"

cat <<EOF
Created $project_name in ./$target_dir

Next steps:
  cd $target_dir

  git remote add origin <repository-url>
  git add .
  git commit -m "Initial commit"
  git push -u origin master
  
  devenv up
  php artisan migrate:fresh --seed
EOF

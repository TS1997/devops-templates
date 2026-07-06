#!/usr/bin/env bash
# Create a Laravel package project from the bundled template.

set -euo pipefail

package_name=${*:-}
package_vendor=${PACKAGE_VENDOR:-}
default_package_vendor=Bravomedia
filament_plugin_wanted=false
filament_assets_wanted=false
typescript_types_wanted=false

require_template_dir

title_case() {
  local subject=$1

  printf '%s' "$subject" \
    | sed -E 's/[-_]+/ /g; s/(^| )([a-zA-Z0-9])/{\U\2/g; s/[ {]//g'
}

is_valid_vendor() {
  local subject=$1
  local slug

  slug=$(printf '%s' "$subject" | slugify '-')
  [[ -n "$slug" && "$slug" =~ ^[a-z] ]]
}

read_package_vendor() {
  local answer

  if [[ ! -t 0 ]]; then
    package_vendor=$default_package_vendor
    return
  fi

  while true; do
    read -r -p "Vendor [$default_package_vendor]: " answer || fail "Vendor is required."
    answer=${answer:-$default_package_vendor}

    if is_valid_vendor "$answer"; then
      package_vendor=$answer
      return
    fi

    printf 'Vendor must start with a letter.\n' >&2
  done
}

wants_feature() {
  local env_name=$1 prompt=$2
  local answer=${!env_name:-}

  case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
    1|true|yes|y|on)
      return 0
      ;;
    0|false|no|n|off)
      return 1
      ;;
    '')
      ;;
    *)
      fail "$env_name must be one of: yes, no, true, false, 1, 0."
      ;;
  esac

  if [[ ! -t 0 ]]; then
    return 1
  fi

  while true; do
    read -r -p "$prompt [y/N] " answer || return 1

    case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
      y|yes)
        return 0
        ;;
      ''|n|no)
        return 1
        ;;
      *)
        printf 'Please answer yes or no.\n' >&2
        ;;
    esac
  done
}

strip_feature_markers() {
  local file=$1 marker=$2

  [[ -f "$file" ]] || return 0

  sed -i \
    -e "/# BEGIN $marker$/d" \
    -e "/# END $marker$/d" \
    -e "\|// BEGIN $marker$|d" \
    -e "\|// END $marker$|d" \
    -e "/<!-- BEGIN $marker -->/d" \
    -e "/<!-- END $marker -->/d" \
    "$file"
}

remove_feature_blocks() {
  local file=$1 marker=$2

  [[ -f "$file" ]] || return 0

  sed -i \
    -e "/# BEGIN $marker$/,/# END $marker$/d" \
    -e "\|// BEGIN $marker$|,\|// END $marker$|d" \
    -e "/<!-- BEGIN $marker -->/,/<!-- END $marker -->/d" \
    "$file"
}

configure_filament_plugin_template() {
  if [[ "$filament_plugin_wanted" == true ]]; then
    sed -i \
      -e '/<!-- BEGIN FILAMENT_PLUGIN -->/d' \
      -e '/<!-- END FILAMENT_PLUGIN -->/d' \
      "$target_dir/README.md"
  else
    sed -i \
      -e '/<!-- BEGIN FILAMENT_PLUGIN -->/,/<!-- END FILAMENT_PLUGIN -->/d' \
      "$target_dir/README.md"

    rm -rf "$target_dir/src/Filament"
  fi

  # Filament is also required by the Filament assets setup, so only drop the
  # dependency when neither Filament feature is wanted.
  if [[ "$filament_plugin_wanted" == false && "$filament_assets_wanted" == false ]]; then
    sed -i \
      -e '/"filament\/filament":/d' \
      "$target_dir/composer.json"
  fi
}

configure_filament_assets_template() {
  local marker=FILAMENT_ASSETS
  local file
  local files=(
    "$target_dir/src/SkeletonServiceProvider.php"
    "$target_dir/devenv.nix"
    "$target_dir/.gitattributes"
    "$target_dir/README.md"
    "$target_dir/.vscode/extensions.json"
    "$target_dir/.vscode/settings.json"
  )

  if [[ "$filament_assets_wanted" == true ]]; then
    for file in "${files[@]}"; do
      strip_feature_markers "$file" "$marker"
    done

    return
  fi

  for file in "${files[@]}"; do
    remove_feature_blocks "$file" "$marker"
  done

  rm -f "$target_dir/vite.config.js" "$target_dir/package.json"
  rm -rf "$target_dir/resources/assets"
}

configure_typescript_types_template() {
  local marker=TYPESCRIPT_TYPES
  local file
  local files=(
    "$target_dir/src/SkeletonServiceProvider.php"
    "$target_dir/devenv.nix"
    "$target_dir/.gitattributes"
    "$target_dir/.gitignore"
    "$target_dir/README.md"
  )

  if [[ "$typescript_types_wanted" == true ]]; then
    for file in "${files[@]}"; do
      strip_feature_markers "$file" "$marker"
    done

    # The types watcher relies on chokidar. When the Filament assets setup is
    # not included (which ships a full package.json), provide a minimal one
    # containing just that dependency.
    if [[ "$filament_assets_wanted" == false ]]; then
      cat > "$target_dir/package.json" <<'JSON'
{
    "devDependencies": {
        "chokidar": "^5.0.0"
    }
}
JSON
    fi

    return
  fi

  for file in "${files[@]}"; do
    remove_feature_blocks "$file" "$marker"
  done

  sed -i \
    -e '/"spatie\/laravel-data":/d' \
    -e '/"spatie\/laravel-typescript-transformer":/d' \
    -e '/"ts1997\/laravel-package-types":/d' \
    "$target_dir/composer.json"

  rm -rf "$target_dir/resources/types"
}

replace_template_placeholders() {
  local class_name vendor_namespace vendor_slug
  local class_name_replacement vendor_name_replacement vendor_namespace_replacement vendor_slug_replacement package_slug_replacement package_name_replacement description_replacement
  local config_file

  class_name=$(title_case "$package_name")
  vendor_namespace=$(title_case "$package_vendor")
  vendor_slug=$(printf '%s' "$package_vendor" | slugify '-')

  class_name_replacement=$(escape_sed_replacement "$class_name")
  vendor_name_replacement=$(escape_sed_replacement "$package_vendor")
  vendor_namespace_replacement=$(escape_sed_replacement "$vendor_namespace")
  vendor_slug_replacement=$(escape_sed_replacement "$vendor_slug")
  package_slug_replacement=$(escape_sed_replacement "$folder_slug")
  package_name_replacement=$(escape_sed_replacement "$package_name")
  description_replacement=$(escape_sed_replacement "${PACKAGE_DESCRIPTION:-$package_name}")

  while IFS= read -r -d '' file; do
    sed -i \
      -e "s|{{vendor_name}}|$vendor_name_replacement|g" \
      -e "s|{{vendor_namespace}}|$vendor_namespace_replacement|g" \
      -e "s|{{vendor_slug}}|$vendor_slug_replacement|g" \
      -e "s|PackageVendor|$vendor_namespace_replacement|g" \
      -e "s|{{package_name}}|$package_name_replacement|g" \
      -e "s|{{package_slug}}|$package_slug_replacement|g" \
      -e "s|{{package_description}}|$description_replacement|g" \
      -e "s|{{class_name}}|$class_name_replacement|g" \
      -e "s|Skeleton|$class_name_replacement|g" \
      "$file"
  done < <(find "$target_dir" -type f \
    ! -path "$target_dir/vendor/*" \
    ! -path "$target_dir/node_modules/*" \
    -print0)

  [[ ! -f "$target_dir/src/Skeleton.php" ]] || mv "$target_dir/src/Skeleton.php" "$target_dir/src/$class_name.php"
  [[ ! -f "$target_dir/src/Filament/SkeletonPlugin.php" ]] || mv "$target_dir/src/Filament/SkeletonPlugin.php" "$target_dir/src/Filament/${class_name}Plugin.php"
  [[ ! -f "$target_dir/src/SkeletonServiceProvider.php" ]] || mv "$target_dir/src/SkeletonServiceProvider.php" "$target_dir/src/${class_name}ServiceProvider.php"
  [[ ! -f "$target_dir/src/Facades/Skeleton.php" ]] || mv "$target_dir/src/Facades/Skeleton.php" "$target_dir/src/Facades/$class_name.php"
  [[ ! -f "$target_dir/src/Commands/SkeletonCommand.php" ]] || mv "$target_dir/src/Commands/SkeletonCommand.php" "$target_dir/src/Commands/${class_name}Command.php"

  config_file="$target_dir/config/skeleton.php"
  [[ ! -f "$config_file" ]] || mv "$config_file" "$target_dir/config/$folder_slug.php"

  [[ ! -f "$target_dir/resources/assets/css/skeleton.css" ]] || mv "$target_dir/resources/assets/css/skeleton.css" "$target_dir/resources/assets/css/$folder_slug.css"
}

if [[ -z "$package_name" ]]; then
  read -r -p "Package name: " package_name || fail "Package name is required."
fi

[[ -n "$package_name" ]] || fail "Package name is required."

if [[ -z "$package_vendor" ]]; then
  read_package_vendor
fi

[[ -n "$package_vendor" ]] || fail "Vendor is required."
is_valid_vendor "$package_vendor" || fail "Package vendor must start with a letter."

if wants_feature FILAMENT_PLUGIN "Include a Filament plugin scaffold?"; then
  filament_plugin_wanted=true
fi

if wants_feature FILAMENT_ASSETS "Include a Filament assets (CSS) build setup?"; then
  filament_assets_wanted=true
fi

if wants_feature TYPESCRIPT_TYPES "Generate TypeScript types?"; then
  typescript_types_wanted=true
fi

folder_slug=$(printf '%s' "$package_name" | slugify '-')
vendor_slug=$(printf '%s' "$package_vendor" | slugify '-')

[[ -n "$folder_slug" ]] || fail "Unable to derive a package directory from '$package_name'. Use at least one letter or number."
[[ -n "$vendor_slug" ]] || fail "Unable to derive a package vendor from '$package_vendor'. Use at least one letter or number."

target_dir=$folder_slug

[[ ! -e "$target_dir" ]] || fail "Target directory already exists: ./$target_dir"

mkdir "$target_dir" || fail "Failed to create package directory: ./$target_dir"
copy_template "$target_dir" || fail "Failed to copy template files into ./$target_dir"

[[ -f "$target_dir/devenv.nix" ]] || fail "Template copy completed, but ./$target_dir/devenv.nix is missing."
configure_filament_plugin_template || fail "Failed to configure Filament plugin files in ./$target_dir"
configure_filament_assets_template || fail "Failed to configure Filament assets files in ./$target_dir"
configure_typescript_types_template || fail "Failed to configure TypeScript types files in ./$target_dir"
replace_template_placeholders || fail "Failed to configure Laravel package in ./$target_dir"
git -C "$target_dir" init -b master || fail "Failed to initialize a Git repository in ./$target_dir"

cat <<EOF
Created Laravel package project in ./$target_dir

Next steps:
  cd $target_dir

  git remote add origin <repository-url>
  git add .
  git commit -m "Initial commit"
  git push -u origin master
  
  composer install
  composer test
EOF

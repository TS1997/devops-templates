#!/usr/bin/env bash
# Create a Laravel package project from the bundled template.

set -euo pipefail

package_name=${*:-}
filament_plugin_wanted=false

require_template_dir

title_case() {
  local subject=$1

  printf '%s' "$subject" \
    | sed -E 's/[-_]+/ /g; s/(^| )([a-zA-Z0-9])/{\U\2/g; s/[ {]//g'
}

title_snake() {
  local subject=$1

  printf '%s' "$subject" | sed -E 's/[-_]+/_/g'
}

remove_prefix() {
  local prefix=$1
  local subject=$2

  if [[ "$subject" == "$prefix"* ]]; then
    printf '%s' "${subject#"$prefix"}"
  else
    printf '%s' "$subject"
  fi
}

wants_filament_plugin() {
  local answer=${FILAMENT_PLUGIN:-}

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
      fail "FILAMENT_PLUGIN must be one of: yes, no, true, false, 1, 0."
      ;;
  esac

  if [[ ! -t 0 ]]; then
    return 1
  fi

  while true; do
    read -r -p "Include a Filament plugin scaffold? [y/N] " answer || return 1

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

configure_filament_plugin_template() {
  if [[ "$filament_plugin_wanted" == true ]]; then
    sed -i \
      -e '/<!-- BEGIN FILAMENT_PLUGIN -->/d' \
      -e '/<!-- END FILAMENT_PLUGIN -->/d' \
      "$target_dir/README.md"

    return
  fi

  sed -i \
    -e '/<!-- BEGIN FILAMENT_PLUGIN -->/,/<!-- END FILAMENT_PLUGIN -->/d' \
    "$target_dir/README.md"

  sed -i \
    -e '/"filament\/filament":/d' \
    "$target_dir/composer.json"

  rm -rf "$target_dir/src/Filament"
}

replace_template_placeholders() {
  local class_name class_name_replacement package_slug_replacement package_name_replacement description_replacement
  local migration_table_replacement package_slug_without_prefix config_file migration_file

  class_name=$(title_case "$package_name")
  package_slug_without_prefix=$(remove_prefix 'laravel-' "$folder_slug")

  class_name_replacement=$(escape_sed_replacement "$class_name")
  package_slug_replacement=$(escape_sed_replacement "$folder_slug")
  package_name_replacement=$(escape_sed_replacement "$package_name")
  description_replacement=$(escape_sed_replacement "${PACKAGE_DESCRIPTION:-$package_name_replacement}")
  migration_table_replacement=$(escape_sed_replacement "$(title_snake "$folder_slug")")

  while IFS= read -r -d '' file; do
    sed -i \
      -e "s|{{package_name}}|$package_name_replacement|g" \
      -e "s|{{package_slug}}|$package_slug_replacement|g" \
      -e "s|{{package_description}}|$description_replacement|g" \
      -e "s|{{class_name}}|$class_name_replacement|g" \
      -e "s|Skeleton|$class_name_replacement|g" \
      -e "s|{{migration_table_name}}|$migration_table_replacement|g" \
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

  migration_file="$target_dir/database/migrations/create_skeleton_table.php.stub"
  [[ ! -f "$migration_file" ]] || mv "$migration_file" "$target_dir/database/migrations/create_$(title_snake "$package_slug_without_prefix")_table.php.stub"

  config_file="$target_dir/config/skeleton.php"
  [[ ! -f "$config_file" ]] || mv "$config_file" "$target_dir/config/$package_slug_without_prefix.php"
}

if [[ -z "$package_name" ]]; then
  read -r -p "Package name: " package_name || fail "Package name is required."
fi

[[ -n "$package_name" ]] || fail "Package name is required."

if wants_filament_plugin; then
  filament_plugin_wanted=true
fi

folder_slug=$(printf '%s' "$package_name" | slugify '-')

[[ -n "$folder_slug" ]] || fail "Unable to derive a package directory from '$package_name'. Use at least one letter or number."

target_dir=$folder_slug

[[ ! -e "$target_dir" ]] || fail "Target directory already exists: ./$target_dir"

mkdir "$target_dir" || fail "Failed to create package directory: ./$target_dir"
copy_template || fail "Failed to copy template files into ./$target_dir"

[[ -f "$target_dir/devenv.nix" ]] || fail "Template copy completed, but ./$target_dir/devenv.nix is missing."
configure_filament_plugin_template || fail "Failed to configure Filament plugin files in ./$target_dir"
replace_template_placeholders || fail "Failed to configure Laravel package in ./$target_dir"

cat <<EOF
Created Laravel package project in ./$target_dir

Next steps:
  cd $target_dir
  composer test
EOF

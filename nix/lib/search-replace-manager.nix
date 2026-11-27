{ pkgs, lib }:
let
  # Replaces the source environment's home URL with the target environment's
  # own in the target's database. The source is only read from.
  mkSearchReplace =
    {
      devenvRoot,
      hostsAttr,
      sourceEnvironment,
      targetEnvironment,
      name ? "search-replace-${targetEnvironment}",
    }:
    assert lib.assertMsg (
      sourceEnvironment != targetEnvironment
    ) "mkSearchReplace: source and target are both '${targetEnvironment}'.";
    assert lib.assertMsg (
      targetEnvironment != "production"
    ) "mkSearchReplace: refusing to make a script that writes to production.";

    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.jq
        pkgs.openssh
      ];
      text = ''
        script_name=${lib.escapeShellArg name}
        hosts_attr=${lib.escapeShellArg hostsAttr}
        source_env=${lib.escapeShellArg sourceEnvironment}
        target_env=${lib.escapeShellArg targetEnvironment}

        dry_run=
        confirmed=
        for argument in "$@"; do
          case "$argument" in
            --dry-run) dry_run=1 ;;
            --yes | -y) confirmed=1 ;;
            *)
              echo "Usage: $script_name [--dry-run] [--yes]" >&2
              echo "Replaces $source_env's URL with $target_env's own URL in the $target_env database." >&2
              echo "$source_env is only ever read from (home URL lookup), never written to." >&2
              exit 1
              ;;
          esac
        done

        remote_wp() {
          local host="$1" user="$2"
          shift 2
          printf -v wp_args '%q ' "$@"
          # shellcheck disable=SC2029 # wp_args is quoted above for the remote shell
          ssh "$user@$host" "if [ -d current ]; then cd current; fi && exec nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#wp-cli --command wp --path=\"\$PWD/public/wp\" --skip-plugins --skip-themes $wp_args"
        }

        cd ${lib.escapeShellArg devenvRoot}
        hosts="$(devenv eval "$hosts_attr" | jq -c '.[]')"
        for environment_name in "$source_env" "$target_env"; do
          if ! jq -e --arg env "$environment_name" 'has($env)' <<<"$hosts" >/dev/null; then
            echo "$hosts_attr has no $environment_name entry; set it in devenv.nix." >&2
            exit 1
          fi
        done

        source_host="$(jq -r --arg env "$source_env" '.[$env].host' <<<"$hosts")"
        source_user="$(jq -r --arg env "$source_env" '.[$env].user' <<<"$hosts")"
        target_host="$(jq -r --arg env "$target_env" '.[$env].host' <<<"$hosts")"
        target_user="$(jq -r --arg env "$target_env" '.[$env].user' <<<"$hosts")"

        echo "Reading the site URL from $source_env ($source_host) — read-only ..." >&2
        source_url="$(remote_wp "$source_host" "$source_user" option get home)"
        source_url="''${source_url%/}"
        echo "Reading the site URL from $target_env ($target_host) ..." >&2
        target_url="$(remote_wp "$target_host" "$target_user" option get home)"
        target_url="''${target_url%/}"

        if [[ -z "$source_url" || -z "$target_url" ]]; then
          echo "Could not read the site URL from $source_env and/or $target_env." >&2
          exit 1
        fi

        if [[ "$source_url" == "$target_url" ]]; then
          echo "$source_env and $target_env already report the same URL ($source_url); nothing to do." >&2
          exit 0
        fi

        # Without the scheme, so http://, https:// and protocol-relative URLs
        # all match; plus the JSON-escaped and URL-encoded forms. One
        # search-replace pass per pair.
        source_address="''${source_url#*://}"
        target_address="''${target_url#*://}"
        search_terms=(
          "//$source_address"
          "\\/\\/''${source_address//\//\\/}"
          "%2F%2F''${source_address//\//%2F}"
        )
        replace_terms=(
          "//$target_address"
          "\\/\\/''${target_address//\//\\/}"
          "%2F%2F''${target_address//\//%2F}"
        )

        echo >&2
        echo "In the ''${target_env^^} database ($target_host) ONLY, will replace:" >&2
        for term_index in "''${!search_terms[@]}"; do
          echo "  ''${search_terms[$term_index]}  ->  ''${replace_terms[$term_index]}" >&2
        done
        echo "$source_env ($source_host) is never written to by this script." >&2
        echo >&2

        if [[ -z "$confirmed" && -z "$dry_run" ]]; then
          read -r -p "Type 'yes' to continue: " answer
          if [[ "$answer" != "yes" ]]; then
            echo "Aborted." >&2
            exit 1
          fi
        fi

        dry_run_flag=()
        if [[ -n "$dry_run" ]]; then
          dry_run_flag=(--dry-run)
        fi

        # guid must stay unchanged (feed readers use it as a permanent id).
        for term_index in "''${!search_terms[@]}"; do
          remote_wp "$target_host" "$target_user" \
            search-replace "''${search_terms[$term_index]}" "''${replace_terms[$term_index]}" \
            --all-tables --skip-columns=guid --report-changed-only "''${dry_run_flag[@]}"
        done

        if [[ -z "$dry_run" ]]; then
          # The object cache (Redis) still holds the old URLs.
          if ! remote_wp "$target_host" "$target_user" cache flush; then
            echo "Warning: could not flush the object cache on $target_env; flush it manually." >&2
          fi
        fi
      '';
    };
in
{
  inherit mkSearchReplace;
}

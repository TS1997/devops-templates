{ pkgs, lib }:
let
  pullBackup = pkgs.writeShellApplication {
    name = "pull-backup";
    runtimeInputs = [
      pkgs.openssh
      pkgs.gnutar
    ];
    text = ''
      db_only=
      if [[ "''${1:-}" == --db-only ]]; then
        db_only=1
        shift
      fi
      if (( $# < 2 || $# > 4 )); then
        echo "Usage: pull-backup [--db-only] HOST SITENAME [ENV=production] [SNAPSHOT=latest]" >&2
        exit 1
      fi

      host="$1"
      site_name="$2"
      env="''${3:-production}"
      snapshot="''${4:-latest}"
      database_dump_dir="/var/backup/restic-dumps/$site_name"
      
      if [[ -n "$db_only" ]]; then
        path="$database_dump_dir"
      else
        path=/
      fi

      backups="$PWD/backups"
      out="$backups/$env/$snapshot"
      if [[ -n "$(ls -A "$out" 2>/dev/null)" ]]; then
        echo "$out already exists; remove it to pull again." >&2
        exit 1
      fi
      mkdir -p "$out"
      # Keep pulled backups out of git.
      [[ -f "$backups/.gitignore" ]] || echo '*' > "$backups/.gitignore"

      # restic-<siteName> is the root-only wrapper NixOS installs for the
      # site's backup job.
      printf -v remote '%q ' "restic-$site_name" dump --archive tar "$snapshot" "$path"
      echo "Pulling $path from snapshot $snapshot of $site_name from root@$host into $out ..." >&2
      # shellcheck disable=SC2029 # $remote is quoted above for the remote shell
      if ! ssh "root@$host" "$remote" | tar -x -C "$out"; then
        rm -rf "$out"
        exit 1
      fi
      echo "Done. Database dumps are in $out$database_dump_dir/." >&2
    '';
  };
in
{
  inherit pullBackup;

  mkPullDevenvBackup =
    {
      devenvRoot,
      hostsAttr,
    }:
    pkgs.writeShellApplication {
      name = "pull-devenv-backup";
      runtimeInputs = [ pkgs.jq ];
      text = ''
        flags=()
        if [[ "''${1:-}" == --db-only ]]; then
          flags=(--db-only)
          shift
        fi
        if (( $# > 2 )); then
          echo "Usage: pull-devenv-backup [--db-only] [ENV=production] [SNAPSHOT=latest]" >&2
          exit 1
        fi
        env="''${1:-production}"
        snapshot="''${2:-latest}"

        cd ${lib.escapeShellArg devenvRoot}
        hosts="$(devenv eval ${lib.escapeShellArg hostsAttr} | jq -c '.[]')"
        if ! jq -e --arg env "$env" 'has($env)' <<<"$hosts" >/dev/null; then
          echo "${hostsAttr} has no $env; use pull-backup HOST SITENAME for other hosts." >&2
          exit 1
        fi
        exec ${lib.getExe pullBackup} "''${flags[@]}" \
          "$(jq -r --arg env "$env" '.[$env].host' <<<"$hosts")" \
          "$(jq -r --arg env "$env" '.[$env].siteName' <<<"$hosts")" \
          "$env" "$snapshot"
      '';
    };
}

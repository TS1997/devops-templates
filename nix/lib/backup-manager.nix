{ pkgs, lib }:
{
  # Root of the devenv project; backups are written to <root>/backups.
  devenvRoot,
  # Attribute path of the site's hosts option, e.g.
  # "services.ts1997.laravelSite.hosts". Read with `devenv eval`.
  hostsAttr,
}:
{
  # pull-backup [ENV=production] [SNAPSHOT=latest]: downloads a restic snapshot
  # of hosts.<env>.siteName from root@hosts.<env>.host into
  # backups/<env>/<snapshot>/.
  pullBackup = pkgs.writeShellApplication {
    name = "pull-backup";
    runtimeInputs = [
      pkgs.jq
      pkgs.openssh
      pkgs.gnutar
    ];
    text = ''
      env="''${1:-production}"
      snapshot="''${2:-latest}"

      cd ${lib.escapeShellArg devenvRoot}
      host="$(devenv eval "${hostsAttr}.$env.host" | jq -r '.[]')"
      siteName="$(devenv eval "${hostsAttr}.$env.siteName" | jq -r '.[]')"

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
      printf -v remote '%q ' "restic-$siteName" dump --archive tar "$snapshot" /
      echo "Pulling snapshot $snapshot of $siteName from root@$host into $out ..." >&2
      # shellcheck disable=SC2029 # $remote is quoted above for the remote shell
      if ! ssh "root@$host" "$remote" | tar -x -C "$out"; then
        rm -rf "$out"
        exit 1
      fi
      echo "Done. Database dumps are in $out/var/backup/restic-dumps/$siteName/." >&2
    '';
  };
}

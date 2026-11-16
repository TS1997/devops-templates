{
  config,
  lib,
  pkgs,
  ...
}:
let
  nginxCfg = config.services.ts1997.nginx;
  sslEnabled =
    nginxCfg.enable
    && lib.any (vhostCfg: vhostCfg.enableSsl) (lib.attrValues nginxCfg.virtualHosts);

  caFile = "${config.env.DEVENV_STATE}/mkcert/rootCA.pem";
  caNickname = "mkcert ${baseNameOf config.env.DEVENV_ROOT}";

  # mkcert -install only knows ~/.mozilla/firefox and ~/.pki/nssdb; this also covers
  # Zen, LibreWolf, Floorp, XDG-style Firefox profiles, Flatpak/Snap and macOS profiles.
  trustLocalCa = pkgs.writeShellApplication {
    name = "trust-local-ca";
    runtimeInputs = [
      pkgs.nss.tools
      pkgs.coreutils
    ];
    text = ''
      shopt -s nullglob

      ca_file=${lib.escapeShellArg caFile}
      ca_nickname=${lib.escapeShellArg caNickname}
      config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      mac_support="$HOME/Library/Application Support"

      if [[ ! -f "$ca_file" ]]; then
        echo "No CA found at $ca_file. Start the dev environment (devenv up) first." >&2
        exit 1
      fi

      declare -A handled_profiles=()
      trusted_count=0

      for cert_db in \
        "$HOME"/.mozilla/firefox/*/cert9.db \
        "$config_home"/mozilla/firefox/*/cert9.db \
        "$config_home"/zen/*/cert9.db \
        "$HOME"/.zen/*/cert9.db \
        "$HOME"/.librewolf/*/cert9.db \
        "$HOME"/.floorp/*/cert9.db \
        "$HOME"/.var/app/*/.mozilla/firefox/*/cert9.db \
        "$HOME"/.var/app/*/.zen/*/cert9.db \
        "$HOME"/snap/firefox/common/.mozilla/firefox/*/cert9.db \
        "$mac_support"/Firefox/Profiles/*/cert9.db \
        "$mac_support"/zen/Profiles/*/cert9.db \
        "$mac_support"/librewolf/Profiles/*/cert9.db \
        "$HOME"/.pki/nssdb/cert9.db \
        "$data_home"/pki/nssdb/cert9.db
      do
        profile_dir=$(realpath "$(dirname "$cert_db")")
        [[ -n "''${handled_profiles[$profile_dir]:-}" ]] && continue
        handled_profiles[$profile_dir]=1

        # Remove a stale CA with the same nickname (e.g. after .devenv/state was wiped)
        while certutil -D -d "sql:$profile_dir" -n "$ca_nickname" 2>/dev/null; do :; done

        if certutil -A -d "sql:$profile_dir" -t "C,," -n "$ca_nickname" -i "$ca_file"; then
          echo "Trusted in: $profile_dir"
          trusted_count=$((trusted_count + 1))
        else
          echo "Failed for: $profile_dir" >&2
        fi
      done

      if [[ $trusted_count -eq 0 ]]; then
        echo "No NSS certificate databases found." >&2
        exit 1
      fi

      echo "Restart your browser(s) to pick up the CA."
    '';
  };
in
{
  config = lib.mkIf sslEnabled {
    packages = [ trustLocalCa ];
  };
}

{ config, lib, ... }:
let
  nginxCfg = config.services.ts1997.nginx;

  appUrls = lib.concatStringsSep "\n\n" (
    lib.mapAttrsToList (vhostName: vhostCfg: ''
      echo "┌─ App: ${vhostName}"
      ${lib.optionalString (vhostCfg.enableSsl) ''
        echo "│  https://${vhostCfg.serverName}:${toString vhostCfg.sslPort}/"
      ''}
      echo "│  http://${vhostCfg.serverName}:${toString vhostCfg.port}/"
      echo "└─────────────────────────────────────────────"
      echo ""
    '') nginxCfg.virtualHosts
  );
in
{
  config.processes.app-urls.exec = ''
    sleep 2
    echo -e "\n"
    ${lib.optionalString (nginxCfg.enable) ''
      echo "═══════════════════════════════════════════════"
      echo "             Application URLs"
      echo "═══════════════════════════════════════════════"
      echo ""
      ${appUrls}
      echo -e "\n"
    ''}
  '';
}

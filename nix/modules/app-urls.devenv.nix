{ config, lib, ... }:
let
  nginxCfg = config.services.ts1997.nginx;

  appUrls = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: vhostCfg:
      lib.mkIf vhostCfg.enable ''
        echo "${name}";
        ${lib.optionalString (vhostCfg.enableSsl) ''
          echo "SSL URL: https://${vhostCfg.serverName}:${toString vhostCfg.sslPort}/";
        ''}
        echo "URL: http://${vhostCfg.serverName}:${toString vhostCfg.port}/";
        echo -e "\n";
      ''
    ) nginxCfg.virtualHosts
  );
in
{
  config.processes.app-urls.exec = ''
    ${lib.optionalString (nginxCfg.enable) ''
      echo "App URLs:";
      echo "${appUrls}";
    ''}
  '';
}

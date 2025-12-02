{ config, lib, ... }:
let
  nginxCfg = config.services.ts1997.nginx;
  vhostCfg = nginxCfg.virtualHost;

  appUrls = ''
    ${lib.optionalString (vhostCfg.enableSsl) ''
      "SSL URL: https://${vhostCfg.serverName}:${toString vhostCfg.sslPort}/"
    ''}
    "URL: http://${vhostCfg.serverName}:${toString vhostCfg.port}/"
  '';
in
{
  config.processes.app-urls.exec = ''
    sleep 2
    echo -e "\n"
    ${lib.optionalString (nginxCfg.enable) ''
      echo "App URLs:"
      echo -e "${appUrls}\n"
    ''}
  '';
}

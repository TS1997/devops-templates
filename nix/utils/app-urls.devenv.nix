{ config, lib, ... }:
let
  nginxCfg = config.services.ts1997.nginx;
  phpMyAdminCfg = config.services.ts1997.mysql.phpmyadmin;
  mailpitCfg = config.services.ts1997.mailpit;

  # Helper functions
  repeat = str: n: lib.concatStrings (lib.replicate n str);

  # ANSI escape codes
  bold = text: "\\033[1m${text}\\033[0m";

  box = {
    top = width: "╔${repeat "═" width}╗";
    bottom = width: "╚${repeat "═" width}╝";
    line =
      text: width:
      let
        baseLength = lib.stringLength text;
        padding = width - 2 - baseLength;
      in
      "║  ${bold text}${repeat " " padding}║";
  };

  vhost = {
    header = name: "╭─ ${bold name}";
    ssl = url: "│  🔒 ${url}";
    http = url: "│  🌐 ${url}";
    footer = "╰${repeat "─" 50}";
  };

  section = title: content: ''
    echo -e "\n"
    echo -e "${box.top 52}"
    echo -e "${box.line title 52}"
    echo -e "${box.bottom 52}"
    echo -e ""
    ${content}
  '';

  appUrls = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (vhostName: vhostCfg: ''
      echo -e "  ${vhost.header vhostName}"
      ${lib.optionalString (vhostCfg.enableSsl) ''
        echo -e "  ${vhost.ssl "https://${vhostCfg.serverName}:${toString vhostCfg.sslPort}/"}"
      ''}
      echo -e "  ${vhost.http "http://${vhostCfg.serverName}:${toString vhostCfg.port}/"}"
      echo -e "  ${vhost.footer}"
    '') nginxCfg.virtualHosts
  );

  dbManagementUrls = lib.concatStringsSep "\n" (
    lib.optionals (phpMyAdminCfg.enable) [
      ''echo -e "  ${vhost.header "phpMyAdmin"}"''
      ''echo -e "  ${vhost.http "http://${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port}/"}"''
      ''echo -e "  ${vhost.footer}"''
    ]
  );

  showDbManagement = phpMyAdminCfg.enable;
in
{
  config.processes.app-urls.exec = ''
    sleep 2

    ${lib.optionalString (nginxCfg.enable) (section "Application URLs" appUrls)}

    ${lib.optionalString (showDbManagement) (section "Database Management" dbManagementUrls)}

    ${lib.optionalString (mailpitCfg.enable) (
      section "Mailpit URLs" ''
        echo -e "  ${vhost.header "Mailpit UI"}"
        echo -e "  ${vhost.http "http://${mailpitCfg.ui.host}:${toString mailpitCfg.ui.port}/"}"
        echo -e "  ${vhost.footer}"
        echo -e ""
      ''
    )}

    echo ""
  '';
}

{ config }:
let
  nginxCfg = config.services.ts1997.nginx;
  phpmyadminCfg = config.services.ts1997.phpmyadmin;
in
''
  echo -e "\n\nApplication URLs:";
  ${
    if nginxCfg.enable then
      ''
        ${
          if nginxCfg.enableSsl then
            ''
              echo "SSL URL: https://${nginxCfg.serverName}:${toString nginxCfg.sslPort}/"
            ''
          else
            ""
        }
        echo "NON SSL URL: http://${nginxCfg.serverName}:${toString nginxCfg.port}/"
      ''
    else
      ""
  }

  ${
    if phpmyadminCfg.enable then
      ''
        echo -e "\n\nPhpMyAdmin URL:";
        echo "http://${phpmyadminCfg.host}:${toString phpmyadminCfg.port}/"
      ''
    else
      ""
  }

  echo -e "\n"
''

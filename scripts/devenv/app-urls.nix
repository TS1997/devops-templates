{ config }:
let
  nginxCfg = config.services.ts1997.nginx;
  phpmyadminCfg = config.services.ts1997.phpmyadmin;
in
''
  sleep 2; # Wait for services to start properly

  echo -e "\n";
  echo "Application URLs:";
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
        echo "";
        echo "PhpMyAdmin URL:";
        echo "http://${phpmyadminCfg.host}:${toString phpmyadminCfg.port}/"
      ''
    else
      ""
  }

  ${
    if config.services.mailpit.enable then
      ''
        echo "";
        echo "Mailpit URL:";
        echo "http://${config.services.mailpit.uiListenAddress}/"
      ''
    else
      ""
  }

  echo -e "\n";
''

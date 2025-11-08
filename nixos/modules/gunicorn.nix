{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.gunicorn;
in
{
  options.services.ts1997.gunicorn = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            appModule = lib.mkOption {
              type = lib.types.str;
              default = "app:app";
              description = "The WSGI application module to run.";
            };

            workingDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/${name}";
              description = "The working directory for Gunicorn.";
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The user to run Gunicorn as.";
            };

            socket = lib.mkOption {
              type = lib.types.str;
              default = "/run/gunicorn/${name}.sock";
              description = "The Unix socket to bind Gunicorn to.";
            };

            workers = lib.mkOption {
              type = lib.types.int;
              default = 4;
              description = "The number of worker processes.";
            };

            timeout = lib.mkOption {
              type = lib.types.int;
              default = 30;
              description = "The number of seconds to wait for requests before timing out.";
            };

            pythonPackages = lib.mkOption {
              type = lib.types.functionTo (lib.types.listOf lib.types.package);
              default = ps: [ ];
              description = "Additional Python packages to include in the environment.";
              example = lib.literalExpression "ps: with ps; [ requests flask ]";
            };

            pythonEnv = lib.mkOption {
              type = lib.types.package;
              readOnly = true;
              internal = true;
              description = "The Python environment with all packages.";
            };
          };

          config = {
            pythonEnv = pkgs.python313.withPackages (
              ps:
              with ps;
              [
                pip
                setuptools
                wheel
                gunicorn
              ]
              ++ (config.pythonPackages ps)
            );
          };
        }
      )
    );
    default = { };
    description = "List of Gunicorn applications to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    systemd.services = lib.mapAttrs' (
      name: gunicornCfg:
      lib.nameValuePair "gunicorn-${name}" {
        description = "Gunicorn service for ${name}";
        after = [ "network.target" ];
        wants = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = gunicornCfg.user;
          WorkingDirectory = gunicornCfg.workingDir;
          RuntimeDirectory = "gunicorn";
          StateDirectory = name;

          ExecStartPre = pkgs.writeShellScript "install-deps" ''
            cd /var/lib/${name}
            if [ -f requirements.txt ]; then
              ${gunicornCfg.pythonEnv}/bin/pip install -r requirements.txt --target ${gunicornCfg.workingDir}/.venv --no-warn-script-location --upgrade
            fi
          '';

          ExecStart = ''
            ${gunicornCfg.pythonEnv}/bin/gunicorn \
            --workers ${toString gunicornCfg.workers} \
            --bind unix:${gunicornCfg.socket} \
            --timeout ${toString gunicornCfg.timeout} \
            ${gunicornCfg.appModule}
          '';

          Environment = "PYTHONPATH=${gunicornCfg.workingDir}/.venv:$PYTHONPATH";

          Restart = "on-failure";
          RestartSec = "5s";
        };
      }
    ) cfg;
  };
}

{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  cfg = config.services.ts1997.gunicorn;
  enabledServers = lib.filterAttrs (_: server: server.enable) cfg.servers;
in
{
  options.services.ts1997.gunicorn = lib.mkOption {
    type = util.submodule {
      options = {
        enable = lib.mkEnableOption "Enable Gunicorn service";

        servers = lib.mkOption {
          type = lib.types.attrsOf (
            util.submodule {
              imports = [
                ./options/gunicorn-server-options.base.nix
                ./options/gunicorn-server-options.nixos.nix
              ];
            }
          );
        };
      };
    };
    default = { };
    description = "Configuration for Gunicorn servers.";
  };

  config = lib.mkIf (cfg.enable) {
    security.sudo.wheelNeedsPassword = false;

    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user}.extraGroups = [ "wheel" ];
        }) enabledServers
      );
    };

    systemd.services = lib.mapAttrs' (
      serverName: serverCfg:
      lib.nameValuePair "gunicorn-${serverName}" {
        description = "Gunicorn server for ${serverName}";
        after = [ "network.target" ];
        wants = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = serverCfg.runtimeDependencies;

        serviceConfig = {
          User = serverCfg.user;
          Group = serverCfg.user;
          WorkingDirectory = serverCfg.workingDir;
          RuntimeDirectory = "gunicorn";
          StateDirectory = serverName;
          Environment = "PYTHONPATH=${serverCfg.workingDir}/.venv:$PYTHONPATH";

          ExecStartPre = pkgs.writeShellScript "install-${serverName}-deps" ''
            cd ${serverCfg.workingDir}
            if [ -f requirements.txt ]; then
              ${serverCfg.fullPackage}/bin/pip install -r requirements.txt \
                --target ${serverCfg.workingDir}/.venv  \
                --no-warn-script-location \
                --upgrade
            fi
          '';

          ExecStart = ''
            ${serverCfg.fullPackage}/bin/gunicorn \
              --chdir ${serverCfg.workingDir} \
              --pythonpath ${serverCfg.workingDir}/${serverCfg.entrypointDir} \
              --workers ${toString serverCfg.workers} \
              --bind unix:${serverCfg.socket} \
              --timeout ${toString serverCfg.timeout} \
              --graceful-timeout ${toString serverCfg.gracefulTimeout} \
              ${serverCfg.entrypoint}
          '';

          KillMode = "mixed";
          KillSignal = "SIGTERM";
          TimeoutStopSec = "30s";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      }
    ) enabledServers;
  };
}

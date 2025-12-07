{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  cfg = config.services.ts1997.gunicorn;
in
{
  options.services.ts1997.gunicorn = lib.mkOption {
    type = util.submodule {
      options = {
        enable = lib.mkEnableOption "Enable Gunicorn service";

        server = lib.mkOption {
          type = util.submodule {
            imports = [
              ./options/gunicorn-server-options.base.nix
              ./options/gunicorn-server-options.devenv.nix
            ];
          };
        };
      };
    };
    default = { };
    description = "Configuration for Gunicorn server.";
  };

  config = lib.mkIf (cfg.enable) {
    packages = [ cfg.server.fullPackage ] ++ cfg.server.runtimeDependencies;

    languages.python = {
      enable = cfg.enable;
      package = cfg.server.fullPackage;
      poetry = {
        enable = true;
        install.enable = true;
      };
    };

    processes = {
      gunicorn.exec = ''
        poetry run gunicorn \
          --chdir ${cfg.server.workingDir} \
          --pythonpath ${cfg.server.workingDir}/${cfg.server.entrypointDir} \
          --workers ${toString cfg.server.workers} \
          --bind unix:${cfg.server.socket} \
          --timeout ${toString cfg.server.timeout} \
          --graceful-timeout ${toString cfg.server.gracefulTimeout} \
          --access-logfile - \
          --error-logfile - \
          --reload \
          ${cfg.server.entrypoint}
      '';
    };

    git-hooks.hooks = {
      poetry-export = {
        enable = true;
        name = "poetry-export";
        description = "Export Poetry dependencies to requirements.txt";
        entry = toString (
          pkgs.writeShellScript "poetry-export" ''
            if poetry self show plugins 2>/dev/null | grep -q poetry-plugin-export; then
              if [ pyproject.toml -nt requirements.txt ] || [ poetry.lock -nt requirements.txt ]; then
                poetry export -f requirements.txt --output requirements.txt --without-hashes
              fi
            fi
          ''
        );
        files = "^(pyproject\\.toml|poetry\\.lock)$";
        pass_filenames = false;
      };
    };
  };
}

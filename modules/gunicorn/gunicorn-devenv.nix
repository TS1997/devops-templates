{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.gunicorn;
in
{
  options.services.ts1997.gunicorn = lib.mkOption {
    type = lib.types.submodule {
      imports = [
        (import ./options/gunicorn-options.nix { inherit lib pkgs; })
      ];

      options = {
        enable = lib.mkEnableOption "Enable Gunicorn Server.";
      };

      config = {
        workingDir = lib.mkDefault config.env.DEVENV_ROOT;
        socket = lib.mkDefault "${config.env.DEVENV_RUNTIME}/gunicorn.sock";
      };
    };
    default = { };
    description = "Gunicorn web server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    env = {
      GUNICORN_SOCKET = cfg.socket;
    };

    languages.python = {
      enable = cfg.enable;
      package = cfg.pythonPackage;
      poetry = {
        enable = true;
        install.enable = true;
      };
    };

    processes = {
      gunicorn.exec = ''
        poetry run gunicorn \
          --workers ${toString cfg.workers} \
          --bind unix:${cfg.socket} \
          --timeout ${toString cfg.timeout} \
          --access-logfile - \
          --error-logfile - \
          --reload \
          ${cfg.appModule}
      '';
    };

    packages = [ cfg.pythonPackage ] ++ cfg.systemPackages;

    git-hooks.hooks = {
      poetry-export = {
        enable = true;
        name = "Export Poetry dependencies";
        entry = "poetry export -f requirements.txt --output requirements.txt --without-hashes";
        language = "system";
        files = "^(pyproject.toml|poetry.lock)$";
        pass_filenames = false;
      };
    };
  };
}

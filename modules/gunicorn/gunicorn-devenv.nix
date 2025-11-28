{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.gunicorn;

  modulePath = builtins.head (builtins.split ":" cfg.appModule);
  moduleFsPath = builtins.replaceStrings [ "." ] [ "/" ] modulePath;
  moduleDir = builtins.dirOf moduleFsPath;
in
{
  options.services.ts1997.gunicorn = lib.mkOption {
    type = lib.types.submodule {
      imports = [
        (import ./gunicorn-options.nix { inherit lib pkgs; })
      ];

      config = {
        workingDir = lib.mkDefault config.env.DEVENV_ROOT;
        socket = lib.mkDefault "${config.env.DEVENV_RUNTIME}/gunicorn.sock";
      };
    };
    default = { };
    description = "Gunicorn application configuration.";
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
          --chdir ${cfg.workingDir} \
          --pythonpath ${cfg.workingDir}/${moduleDir} \
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

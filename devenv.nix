{
  config,
  ...
}:
{
  imports = [
    (import ./nix/utils/util.nix {
      devenvRoot = config.env.DEVENV_ROOT;
      devenvState = config.env.DEVENV_STATE;
      devenvDotfile = config.env.DEVENV_DOTFILE;
      devenvProfile = config.env.DEVENV_PROFILE;
      devenvRuntime = config.env.DEVENV_RUNTIME;
      mysqlSocket = config.env.MYSQL_UNIX_PORT;
      pgsqlSocket = config.services.postgres.settings.unix_socket_directories;
    })
    ./nix/utils/app-urls.devenv.nix
    ./nix/services/devenv.nix
    ./nix/app-services/devenv.nix
  ];

  config = {
    processes = {
      env-config.exec = "devenv info";
    };
  };
}

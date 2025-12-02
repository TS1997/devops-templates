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
    })
    ./nix/modules/app-urls.devenv.nix
    ./nix/services/devenv.nix
    ./nix/app-services/devenv.nix
  ];

  config = {
    processes = {
      env-config.exec = "devenv info";
    };
  };
}

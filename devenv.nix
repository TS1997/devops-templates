{
  config,
  ...
}:
{
  imports = [
    (import ./nix/utils/util.nix {
      devenvRoot = config.env.DEVENV_ROOT;
      devenvState = config.env.DEVENV_STATE;
    })
    ./nix/modules/app-urls.devenv.nix
    ./nix/services/devenv.nix
    # ./frameworks/devenv.nix
  ];

  config = {
    processes = {
      env-config.exec = "devenv info";
    };
  };
}

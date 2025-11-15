{ config, ... }:
let
  mkAppUrls = import ./scripts/app-urls.nix { inherit config; };
in
{
  imports = [
    ./modules/devenv.nix
    ./frameworks/devenv.nix
  ];

  config = {
    processes = {
      env-config.exec = "devenv info";
      app-urls.exec = mkAppUrls;
    };
  };
}

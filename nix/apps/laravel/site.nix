{
  pkgs,
  self,
  flake-utils,
}:
let
  templateDir = "${self}/nix/templates/laravel-site";

  bootstrap = pkgs.writeShellApplication {
    name = "laravel-site-setup";

    runtimeInputs = with pkgs; [
      coreutils
      gnused
      laravel
      openssl
      rsync
    ];

    text = ''
      export TEMPLATE_DIR=${pkgs.lib.escapeShellArg templateDir}

      ${builtins.readFile ./scripts/site-setup.sh}
    '';
  };
in
flake-utils.lib.mkApp {
  drv = bootstrap;
  name = "laravel-site-setup";
}

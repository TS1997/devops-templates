{
  pkgs,
  self,
  flake-utils,
}:
let
  templateDir = "${self}/nix/templates/laravel-package";

  bootstrap = pkgs.writeShellApplication {
    name = "laravel-package-setup";

    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gnused
      rsync
    ];

    text = ''
      export TEMPLATE_DIR=${pkgs.lib.escapeShellArg templateDir}

      ${builtins.readFile ./scripts/common.sh}

      ${builtins.readFile ./scripts/package-setup.sh}
    '';
  };
in
flake-utils.lib.mkApp {
  drv = bootstrap;
  name = "laravel-package-setup";
}

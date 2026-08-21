{
  pkgs,
  flake-utils,
  ...
}:
let
  bootstrap = pkgs.writeShellApplication {
    name = "fix-composer-chsum";

    runtimeInputs = with pkgs; [
      coreutils
      jq
    ];

    text = ''
      # Make backup first
      cp composer.lock composer.lock.bak_"$(date +%Y%m%d_%H%M%S)"

      jq --tab '(.packages[], ."packages-dev"[]) |= if has("dist") then .dist.shasum = "" else . end' composer.lock > composer.lock.tmp && mv composer.lock.tmp composer.lock
    '';
  };
in
flake-utils.lib.mkApp {
  drv = bootstrap;
  name = "fix-composer-chsum";
}

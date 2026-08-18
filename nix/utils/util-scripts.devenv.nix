{ pkgs, ... }:

{
  config = {
    packages = [ pkgs.jq ];
    scripts = {
      fix-composer-chsum = {
        exec = ''
          # Make backup first
          cp composer.lock composer.lock.bak_$(date +%Y%m%d_%H%M%S)

          jq --tab '(.packages[], ."packages-dev"[]) |= if has("dist") then .dist.shasum = "" else . end' composer.lock > composer.lock.tmp && mv composer.lock.tmp composer.lock
        '';
      };
    };
  };

}

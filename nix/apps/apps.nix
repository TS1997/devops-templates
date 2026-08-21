{
  nixpkgs,
  self,
  flake-utils,
}:
flake-utils.lib.eachDefaultSystemMap (
  system:
  let
    pkgs = import nixpkgs { inherit system; };
  in
  {
    laravel-package = import ./laravel/package.nix { inherit pkgs self flake-utils; };
    laravel-site = import ./laravel/site.nix { inherit pkgs self flake-utils; };
    fix-composer-chsum = import ./wordpress/default.nix { inherit pkgs flake-utils; };
  }
)

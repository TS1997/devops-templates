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
    laravel-site = import ./laravel/site.nix { inherit pkgs self flake-utils; };
  }
)

{
  imports = [
    ./mysql/mysql-nixos.nix
    ./nginx/nginx-nixos.nix
    ./phpfpm/phpfpm-nixos.nix
    ./redis/redis-nixos.nix
    ./gunicorn/gunicorn-nixos.nix
  ];
}

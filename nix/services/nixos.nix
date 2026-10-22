{
  imports = [
    ./nginx/nginx.nixos.nix
    ./phpfpm/phpfpm.nixos.nix
    ./mysql/mysql.nixos.nix
    ./pgsql/pgsql.nixos.nix
    ./redis/redis.nixos.nix
    ./opensearch/opensearch.nixos.nix
    ./gunicorn/gunicorn.nixos.nix
  ];
}

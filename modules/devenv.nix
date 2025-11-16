{
  imports = [
    ./mysql/mysql-devenv.nix
    ./pgsql/pgsql-devenv.nix
    ./phpmyadmin/phpmyadmin.nix
    ./nginx/nginx-devenv.nix
    ./phpfpm/phpfpm-devenv.nix
    ./redis/redis-devenv.nix
    ./gunicorn/gunicorn-devenv.nix
  ];
}

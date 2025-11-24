{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.phpmyadmin;

  phpmyadmin = pkgs.stdenv.mkDerivation {
    name = "phpmyadmin";
    src = builtins.fetchurl {
      url = "https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip";
      sha256 = "2d2e13c735366d318425c78e4ee2cc8fc648d77faba3ddea2cd516e43885733f";
    };

    nativeBuildInputs = with pkgs; [
      unzip
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out;

      echo '
        <?php
          $i = 0;
          $i++;

          $cfg["Servers"][$i] = [
            "connect_type" => "socket",
            "socket" => getenv("MYSQL_UNIX_PORT"),
            "auth_type" => "config",
            "user" => "${cfg.database.user}",
            "password" => "${cfg.database.password}",
          ];

      ' > config.inc.php;

      mv ./* $out/;

      runHook postInstall
    '';
  };
in
{
  options.services.ts1997.phpmyadmin = {
    enable = lib.mkEnableOption "Enable phpMyAdmin for database management.";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host where phpMyAdmin will be hosted.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8081;
      description = "The port on which phpMyAdmin will be accessible.";
    };

    database = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        description = "The database user for phpMyAdmin to connect with.";
      };

      password = lib.mkOption {
        type = lib.types.str;
        default = "1234";
        description = "The database password for phpMyAdmin to connect with.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    processes.phpmyadmin.exec = "${config.languages.php.package}/bin/php -S ${cfg.host}:${toString cfg.port} -t ${phpmyadmin}";

    scripts = {
      phpmyadmin.exec = "open http://${cfg.host}:${toString cfg.port}/";
    };
  };
}

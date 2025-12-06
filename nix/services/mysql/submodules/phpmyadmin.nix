{
  dbCfg,
  pkgs,
  util,
  ...
}:
pkgs.stdenv.mkDerivation {
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
        $cfg = [
          "Servers" => [
            1 => [
              "connect_type" => "socket",
              "socket" => "${util.values.mysqlSocket}",
              "auth_type" => "config",
              "user" => "${dbCfg.user}",
              "password" => "${dbCfg.password}",
            ],
          ],
          "TempDir" => "${util.values.devenvState}/phpmyadmin/tmp",
        ];
    ' > config.inc.php;

    mv ./* $out/;

    runHook postInstall
  '';
}

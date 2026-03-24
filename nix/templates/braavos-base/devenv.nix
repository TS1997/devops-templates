{
  pkgs,
  ...
}:
let
  # Select PHP version
  # Search available versions here: https://search.nixos.org/packages?query=php84
  # For older versions, update devenv.yaml with a legacy nixpkgs revision.
  # Search old packages here: https://www.nixhub.io/packages/php
  php = pkgs.php84;

  name = "site";
in
{
  config = {
    name = name;

    services.ts1997.wordpressSite = {
      enable = true;
      domain = "${name}.test";
      appName = name;

      phpPool.basePackage = php;

      database = {
        enable = true;
        name = name;
      };

      assetFallbackUrls = [
        {
          name = "@production";
          url = "https://www.${name}.se";
        }
      ];

      env = {
        WP_ENV = "development";
        ENABLE_BROWSERSYNC_SSL = "true";
        MAIN_DOMAIN = "${name}.test";

        # Salts
        AUTH_KEY = "XE,mXY-S{||k6!n?^^dEN(,&|^(81x2&9z7Q}E)|f/Q/AreAf[2l@PeJ}#Duu-7d";
        SECURE_AUTH_KEY = "=MoZC#4oKJIatd`zNXJhkwoKt=}a^2(S|:bev8DmJ~ashM8m+s~|yi&7%-JHaopn";
        LOGGED_IN_KEY = "kOv,N!({>V6pu4^>_WY-gI0mJ-gUj?!~L8$}e}g$^]w&rC7x7S`#aXK_]1k_[8DZ";
        NONCE_KEY = "leL=BF/u={DxO^NLKEJu<>`D9w#=CDM<(l#(6.}NoM:%,DMwo1*o||=iqArm[Hnw";
        AUTH_SALT = "k8`O;2>EVP03dT4+ ~+i6lk;_mh<`Tu^C<.I*f.V/@K@[+RxG(;rzEaz{WTOj+5}";
        SECURE_AUTH_SALT = "$?Cp3x#/n>;?{_KdDTMAVvFB}U FStQc/?FK+tskkMJh$FeB)8zH[|3#1csPAP{d";
        LOGGED_IN_SALT = "8/x|Ogs.lW82pXzxqPl*5^&)-$!a1-nG+M#il~v!+Setzz=Ua3p4CK)`2~[9#$8s";
        NONCE_SALT = "&ySc(Vk9|NVQ&D4!~f~EHFMDF`=m@||Z3})G@V9~1,v-)R5d6vs0-|W:Ig-VUq$)";
      };
    };

    packages = [ pkgs.git pkgs.wp-cli ];

    scripts.init-assets.exec = ''
      echo "Kopiera bilder från data/uploads till public/content/uploads"
      cp -rf data/uploads public/content

      if [[ $? != 0 ]]; then
        echo "Något gick fel med kopiering av bilderna!"
      else
        echo "Bilderna kopierades utan något problem!"
      fi
    '';

    scripts.reset-db.exec = ''
      echo "Återställer databas..."
      mysql -u admin -p1234 -e "DROP DATABASE IF EXISTS ${name}; CREATE DATABASE ${name};"
      mysql -u admin -p1234 ${name} < data/export.sql
      echo "✓ Databas återställd!"
    '';

    enterShell = ''
      echo ""
      echo "🚀 Utvecklingsmiljön är redo!"
      echo "📚 Databas: ${name}"
      echo "🔗 Webbplats: https://${name}.test"
      echo ""
      echo "💡 Användbara kommandon:"
      echo "  devenv reset-db  # Återställ databasen från export.sql"
      echo "  wp cli           # WordPress CLI"
      echo "  composer install # Installera PHP-paket"
      echo ""
    '';
  };
}

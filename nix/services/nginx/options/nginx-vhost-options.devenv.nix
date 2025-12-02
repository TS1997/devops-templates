{
  config,
  lib,
  util,
  ...
}:
let
  numberOfServerAliases = builtins.length (config.serverAliases);
  sslCertBaseName =
    if (numberOfServerAliases > 0) then
      "${config.serverName}+${toString numberOfServerAliases}"
    else
      config.serverName;
in
{
  options = {
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port that nginx will listen on.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The port that nginx will listen on for SSL.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL for the virtual host.";
    };

    sslCert = lib.mkOption {
      type = lib.types.path;
      default = "${util.devenvState}/mkcert/${sslCertBaseName}.pem";
      description = "Path to the SSL certificate file.";
    };

    sslKey = lib.mkOption {
      type = lib.types.path;
      default = "${util.devenvState}/mkcert/${sslCertBaseName}-key.pem";
      description = "Path to the SSL key file.";
    };
  };
}

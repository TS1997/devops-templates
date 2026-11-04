{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    dumpScript = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      # Root authenticates over the socket.
      default = pkgs.writeShellApplication {
        name = "mysql-dump";
        runtimeInputs = [ config.package ];
        text = ''
          db="''${1:?Usage: mysql-dump DATABASE > FILE}"
          exec mysqldump --single-transaction --routines --triggers -u root "$db"
        '';
      };
      description = "`mysql-dump DATABASE`: writes an SQL dump of a local database to stdout. Run as root.";
    };
  };

  config = {
    socket = "/run/mysqld/mysqld.sock";
  };
}

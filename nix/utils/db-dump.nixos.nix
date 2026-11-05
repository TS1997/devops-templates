{
  config,
  lib,
  pkgs,
  name,
  databases,
}:
pkgs.writeShellApplication {
  name = "db-dump-${name}";
  runtimeInputs = [
    pkgs.gnutar
    pkgs.gzip
  ];
  text = ''
    # /var/tmp rather than /tmp, which may be a RAM-backed tmpfs.
    dir="$(mktemp -d -p /var/tmp "db-dump-${name}.XXXXXX")"
    trap 'rm -rf "$dir"' EXIT
    ${lib.concatMapStringsSep "\n" (
      db:
      "${
        lib.getExe config.services.ts1997.${db.driver}.dumpScript
      } ${lib.escapeShellArg db.name} > \"$dir\"/${lib.escapeShellArg "${db.name}.${db.driver}.sql"}"
    ) databases}
    tar -cz -C "$dir" .
  '';
}

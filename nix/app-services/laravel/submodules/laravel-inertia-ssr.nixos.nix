{
  config,
  lib,
  pkgs,
  ...
}:
let
  sites = config.services.ts1997.laravelSites;
  ssrSites = lib.filterAttrs (_: siteCfg: siteCfg.inertiaSsr.enable) sites;

  dbPackage =
    siteCfg:
    if siteCfg.database.enable then
      (
        if siteCfg.database.driver == "pgsql" then
          [ config.services.ts1997.pgsql.package ]
        else
          [ config.services.ts1997.mysql.package ]
      )
    else
      [ ];

  mkPackages =
    siteCfg:
    [
      (if siteCfg.inertiaSsr.nodejs != null then siteCfg.inertiaSsr.nodejs else pkgs.nodejs_24)
      siteCfg.phpPool.fullPackage
    ]
    ++ dbPackage siteCfg
    ++ siteCfg.inertiaSsr.packages;
in
{
  config = lib.mkIf (ssrSites != { }) {
    systemd.services = lib.mapAttrs' (
      name: siteCfg:
      lib.nameValuePair "laravel-inertia-ssr-${name}" {
        description = "Laravel Inertia SSR server for ${siteCfg.appName}";
        after = [
          "network.target"
          "phpfpm-${name}.service"
        ];
        wants = [ "phpfpm-${name}.service" ];
        wantedBy = [ "multi-user.target" ];

        path = mkPackages siteCfg;

        serviceConfig = {
          Type = "simple";
          User = siteCfg.user;
          Group = siteCfg.user;
          WorkingDirectory = siteCfg.workingDir;
          Restart = "always";
          RestartSec = 10;

          ExecStart = "${pkgs.bash}/bin/bash -c ${lib.escapeShellArg siteCfg.inertiaSsr.command}";
        };
      }
    ) ssrSites;
  };
}

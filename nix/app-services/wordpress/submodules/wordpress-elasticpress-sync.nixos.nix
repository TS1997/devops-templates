{
  config,
  lib,
  pkgs,
  ...
}:
let
  sites = lib.filterAttrs (
    _: siteCfg: siteCfg.enable && siteCfg.opensearch.enable
  ) config.services.ts1997.wordpressSites;

  unitName = name: "elasticpress-sync-${name}";

  # Every domain is synced separately since a single install can serve several
  # sites (e.g. table prefix chosen by host).
  mkScript =
    siteCfg:
    let
      wpCli = pkgs.wp-cli.override { php = siteCfg.phpPool.fullPackage; };
      wpPath = "${siteCfg.webRoot}/wp";
      urls = [ siteCfg.appUrl ] ++ siteCfg.extraAppUrls;
    in
    ''
      if [ ! -f ${wpPath}/wp-load.php ]; then
        echo "WordPress is not deployed to ${wpPath} yet, skipping."
        exit 0
      fi

      wp() {
        ${wpCli}/bin/wp --path=${wpPath} "$@"
      }

      failed=0
      for url in ${lib.escapeShellArgs urls}; do
        if ! wp --url="$url" plugin is-active elasticpress; then
          echo "$url: ElasticPress is not active, skipping."
          continue
        fi

        # 0 = index exists, 1 = missing, anything else = error
        exists=0
        wp --url="$url" eval 'exit(\ElasticPress\Indexables::factory()->get("post")->index_exists() ? 0 : 1);' || exists=$?

        case "$exists" in
          0)
            echo "$url: syncing existing index."
            wp --url="$url" elasticpress sync || failed=1
            ;;
          1)
            echo "$url: index missing, creating and syncing."
            wp --url="$url" elasticpress sync --setup --yes || failed=1
            ;;
          *)
            echo "$url: could not check index (exit $exists)." >&2
            failed=1
            ;;
        esac
      done

      exit "$failed"
    '';
in
{
  config = lib.mkIf (sites != { }) {
    systemd.services = lib.mapAttrs' (
      name: siteCfg:
      lib.nameValuePair (unitName name) {
        description = "ElasticPress sync for ${siteCfg.appName}";
        after = [
          "opensearch.service"
          "phpfpm-${name}.service"
        ]
        ++ lib.optional siteCfg.database.enable "mysql.service";
        wants = [ "opensearch.service" ];

        script = mkScript siteCfg;

        serviceConfig = {
          Type = "oneshot";
          User = siteCfg.user;
          WorkingDirectory = siteCfg.workingDir;
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      }
    ) sites;

    # Runs shortly after the timer starts (boot or first deploy) so new indices get
    # created, then on `opensearch.syncSchedule` as a safety net. ElasticPress keeps
    # the index up to date on post save in between.
    systemd.timers = lib.mapAttrs' (
      name: siteCfg:
      lib.nameValuePair (unitName name) {
        description = "Timer for ElasticPress sync of ${siteCfg.appName}";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnActiveSec = "2min";
          Unit = "${unitName name}.service";
        }
        // lib.optionalAttrs (siteCfg.opensearch.syncSchedule != null) {
          OnCalendar = siteCfg.opensearch.syncSchedule;
          Persistent = true;
          RandomizedDelaySec = "30min";
        };
      }
    ) sites;
  };
}

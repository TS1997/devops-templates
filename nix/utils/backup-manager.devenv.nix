{
  config,
  lib,
  pkgs,
  ...
}:
let
  site =
    if config.services.ts1997.laravelSite.enable then
      "laravelSite"
    else if config.services.ts1997.wordpressSite.enable then
      "wordpressSite"
    else
      null;
  backupManager = import ../lib/backup-manager.nix { inherit pkgs lib; };
in
{
  config = lib.mkIf (site != null) {
    packages = [
      backupManager.pullBackup
      (backupManager.mkPullDevenvBackup {
        devenvRoot = config.devenv.root;
        hostsAttr = "services.ts1997.${site}.hosts";
      })
    ];
  };
}

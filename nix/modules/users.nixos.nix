{ sites }:
{ lib, ... }:
{
  config = {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (_: siteCfg: {
          ${siteCfg.user} = {
            isNormalUser = true;
            createHome = true;
            home = siteCfg.workingDir;
            homeMode = "0750";
            group = siteCfg.user;
            openssh.authorizedKeys.keys = siteCfg.authorizedKeys;
          };
        }) sites
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (_: siteCfg: {
          ${siteCfg.user} = {
            members = [
              siteCfg.user
            ];
          };
        }) sites
      );
    };
  };
}

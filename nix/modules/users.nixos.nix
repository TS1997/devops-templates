{ users }:
{ lib, ... }:
{
  config = {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: user: {
          ${name} = {
            isSystemUser = true;
            createHome = true;
            home = user.home;
            homeMode = "0750";
            group = name;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDObN2rJY9jwRZcOJniUtokZ4XMNN7A8MY5OaeIbhsyx timmy@nixos-xps-15-9510"
            ];
          };
        }) users
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: user: {
          ${name} = {
            members = [
              name
            ];
          };
        }) users
      );
    };
  };
}

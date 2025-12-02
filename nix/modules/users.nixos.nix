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
            group = name;
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

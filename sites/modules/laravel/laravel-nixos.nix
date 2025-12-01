{
  config,
  lib,
  name,
  ...
}:
{
  options = {
    scheduler.enable = lib.mkEnableOption "Enable the Laravel scheduler for ${name}";
  };

  config = {
    services.ts1997.virtualHosts.${name} = {
      serverName = config.domain;
      user = config.user;

      locations."/" = {
        extraConfig = ''
          default_type text/html;
          return 200 "<h1>Welcome to ${name}!</h1>";
        '';
      };
    };
  };
}

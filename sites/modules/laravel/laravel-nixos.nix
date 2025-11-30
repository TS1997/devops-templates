{
  config,
  lib,
  siteName,
  ...
}:
{
  options = {
    scheduler.enable = lib.mkEnableOption "Enable Laravel scheduler for the site.";
  };

  config = {
    services.ts1997.virtualHosts.${siteName} = {
      user = config.user;
      root = config.webRoot;
      serverName = config.domain;
      serverAliases = config.extraDomains;
      forceWWW = config.forceWWW;
      locations."/" = {
        return = "200 '<html><body><h1>Simple HTML Page</h1></body></html>'";
        extraConfig = ''
          add_header Content-Type text/html;
        '';
      };
    };
  };
}

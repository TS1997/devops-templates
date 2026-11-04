{
  config = {
    services.ts1997.laravelPackage = {
      enable = true;
      # BEGIN FILAMENT_ASSETS
      nodejs.enable = true;
      # END FILAMENT_ASSETS
      # BEGIN TYPESCRIPT_TYPES
      generate-types.enable = true;
      # END TYPESCRIPT_TYPES
    };
  };
}

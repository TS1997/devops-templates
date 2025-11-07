{
  pkgs,
  lib,
  mkEnv,
  mkSetFilePermissions,
  ...
}:
let
  mkExportEnv =
    env:
    let
      escapeShell =
        v:
        let
          s = builtins.toString v;
        in
        "'${builtins.replaceStrings [ "'" ] [ "'\"'\"'" ] s}'";
      exports = lib.mapAttrsToList (k: v: "export ${k}=${escapeShell v}") env;
    in
    builtins.concatStringsSep "\n" exports;
in
name: siteCfg:
pkgs.writeShellScriptBin "deploy-${name}" ''
  export PATH="${lib.makeBinPath [ siteCfg.phpPackage ]}:$PATH"
  set -e

  # Load environment variables
  ${mkExportEnv (mkEnv name siteCfg)}

  ARCHIVE_PATH="''${1:-}"

  if [ -z "$ARCHIVE_PATH" ]; then
    echo "Usage: deploy-${name} <path/to/deployment-archive.tar.gz>"
    exit 1
  fi

  if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "Error: File '$ARCHIVE_PATH' does not exist."
    exit 1
  fi

  echo "Starting deployment for ${siteCfg.appName}..."

  cd ${siteCfg.workingDir}

  # Put the application into maintenance mode
  echo "Putting application into maintenance mode..."
  sudo -u ${siteCfg.user} php artisan down || true

  # Extract the new version
  echo "Extracting application files..."
  tar -xzf "$ARCHIVE_PATH" -C ${siteCfg.workingDir}
  rm "$ARCHIVE_PATH"

  # Set file permissions
  echo "Setting file permissions..."
  ${mkSetFilePermissions name siteCfg}

  # Run migrations
  echo "Running database migrations..."
  sudo -u ${siteCfg.user} php artisan migrate --force

  # Clear and cache configurations
  echo "Clearing and caching configurations..."
  sudo -u ${siteCfg.user} php artisan optimize:clear
  sudo -u ${siteCfg.user} php artisan optimize
  sudo -u ${siteCfg.user} php artisan config:cache
  sudo -u ${siteCfg.user} php artisan route:cache
  sudo -u ${siteCfg.user} php artisan view:cache
  sudo -u ${siteCfg.user} php artisan event:cache

  # Restart services
  echo "Restarting PHP-FPM and queue workers..."
  systemctl reload phpfpm-${siteCfg.user}.service
  systemctl restart laravel-queue-${siteCfg.user}-*.service || true

  # Run post-deployment commands if any
  ${lib.optionalString (siteCfg.postDeployCommands != [ ]) ''
    echo "Running post-deployment commands..."
    ${lib.concatMapStringsSep "\n" (cmd: ''
      echo "Executing: ${cmd}"
      ${cmd}
    '') siteCfg.postDeployCommands}
  ''}

  # Bring the application out of maintenance mode
  echo "Bringing application out of maintenance mode..."
  sudo -u ${siteCfg.user} php artisan up

  echo "Deployment for ${siteCfg.appName} completed successfully."
''

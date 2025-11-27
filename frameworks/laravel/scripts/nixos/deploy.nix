{
  lib,
  pkgs,
  name,
  phpPackage,
  siteCfg,
  environmentDefaults,
  ...
}:
let
  mkFilePerms = import ./file-perms.nix { inherit pkgs name siteCfg; };
  mkBuildEnv = import ../../../../scripts/nixos/build-env.nix {
    inherit pkgs name;
    environment = environmentDefaults // siteCfg.environment;
    secretsPath = siteCfg.environmentSecretsPath;
    outputPath = "${siteCfg.workingDir}/.env";
  };
in
pkgs.writeShellScriptBin "deploy-${name}" ''
  export PATH="${lib.makeBinPath [ phpPackage ]}:$PATH"
  set -e

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

  # Generate the environment file
  echo "Generating .env file..."
  ${mkBuildEnv}

  # Set file permissions
  echo "Setting file permissions..."
  ${mkFilePerms}

  # Restart services
  echo "Restarting PHP-FPM and queue workers..."
  systemctl reload phpfpm-${name}.service
  systemctl restart laravel-queue-${name}-*.service || true

  # Run migrations
  echo "Running database migrations..."
  sudo -u ${siteCfg.user} php artisan migrate --force

  # Clear and cache configurations
  echo "Clearing and caching configurations..."
  sudo -u ${siteCfg.user} php artisan optimize:clear
  sudo -u ${siteCfg.user} php artisan optimize

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

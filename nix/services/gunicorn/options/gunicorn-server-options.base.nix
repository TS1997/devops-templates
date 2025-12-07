{
  config,
  lib,
  pkgs,
  ...
}:
let
  basePackages =
    packages: with packages; [
      pip
      setuptools
      wheel
      gunicorn
    ];

  mkEntrypointDir =
    entrypoint:
    let
      path = lib.head (lib.splitString ":" entrypoint);
      fsPath = lib.replaceStrings [ "." ] [ "/" ] path;
    in
    builtins.dirOf (fsPath);
in
{
  options = {
    enable = lib.mkEnableOption "Enable Gunicorn Server";

    basePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python313;
      description = "The Python package to use for the server.";
    };

    pythonPackages = lib.mkOption {
      type = with lib.types; functionTo (listOf (package));
      default = packages: [ ];
      description = "Additional Python packages to install in the Gunicorn environment.";
      example = lib.literalExpression "packages: [ packages.numpy ]";
    };

    fullPackage = lib.mkOption {
      type = lib.types.package;
      default = config.basePackage.withPackages (
        packages: (basePackages packages) ++ (config.pythonPackages packages)
      );
      readOnly = true;
      description = "The Gunicorn package combined with the selected Python packages.";
    };

    runtimeDependencies = lib.mkOption {
      type = lib.types.listOf (lib.types.package);
      default = [ ];
      description = "Additional runtime dependencies for the Gunicorn server.";
    };

    entrypoint = lib.mkOption {
      type = lib.types.str;
      default = "app:app";
      description = "The WSGI application module to run.";
    };

    entrypointDir = lib.mkOption {
      type = lib.types.str;
      default = mkEntrypointDir config.entrypoint;
      description = "The directory containing the WSGI application module.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory for the Gunicorn server.";
    };

    socket = lib.mkOption {
      type = lib.types.path;
      description = "The Unix socket path for Gunicorn to bind to.";
    };

    workers = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "The number of worker processes for handling requests.";
    };

    timeout = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "The number of seconds to wait for requests before timing out.";
    };

    gracefulTimeout = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "The number of seconds to wait for workers to gracefully shut down.";
    };
  };
}

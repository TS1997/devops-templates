{ lib, pkgs }:
{
  options = {
    appModule = lib.mkOption {
      type = lib.types.str;
      default = "app:app";
      description = "The WSGI application module to run.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory for Gunicorn.";
    };

    socket = lib.mkOption {
      type = lib.types.str;
      description = "The Unix socket to bind Gunicorn to.";
    };

    workers = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "The number of worker processes.";
    };

    timeout = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "The number of seconds to wait for requests before timing out.";
    };

    pythonPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python313;
      description = "The Python package to use for Gunicorn.";
    };

    systemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "System Packages that should be available for the gunicorn server";
    };
  };
}

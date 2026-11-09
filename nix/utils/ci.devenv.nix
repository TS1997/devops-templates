{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.ci;
  php = config.languages.php;
  javascript = config.languages.javascript;

  # Existing CI steps use `shell: devenv-run {0}`
  devenvRun = pkgs.writeShellScriptBin "devenv-run" ''
    exec bash -euo pipefail "$@"
  '';
in
{
  options.services.ts1997.ci.packages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    example = lib.literalExpression "[ pkgs.wp-cli ]";
    description = ''
      Tools on PATH in CI. PHP with Composer and Node.js are added when
      enabled; add anything else the build steps need here.
    '';
  };

  config = {
    services.ts1997.ci.packages =
      lib.optionals php.enable (
        [ php.package ] ++ lib.optional (php.packages.composer != null) php.packages.composer
      )
      ++ lib.optional javascript.enable javascript.package;

    # Built by the devenv-setup action instead of the dev shell, so services
    # and other dev-only packages are never built in CI.
    outputs.ci = pkgs.buildEnv {
      name = "ci-tools";
      paths = cfg.packages ++ [ devenvRun ];
    };
  };
}

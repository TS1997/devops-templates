{
  lib,
  name,
  util,
  ...
}:
{
  config = {
    workingDir = lib.mkDefault util.values.devenvRoot;
    socket = lib.mkDefault "${util.values.devenvRuntime}/gunicorn-${name}.sock";
  };
}

{ pkgs, ... }:
name: siteCfg:
pkgs.writeShellScript "laravel-perms-${name}" ''
  chown -R ${siteCfg.user}:${siteCfg.user} ${siteCfg.workingDir}
  chmod -R 750 ${siteCfg.workingDir}
  chmod -R 770 ${siteCfg.workingDir}/storage
  chmod -R 770 ${siteCfg.workingDir}/bootstrap/cache
  chmod 0640 ${siteCfg.workingDir}/.env
''

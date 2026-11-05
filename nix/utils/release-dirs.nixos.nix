# tmpfiles rules for atomic deploys (releases.enable): the deploy workflows
# upload to releases/<id>, link shared paths from shared/ and switch the
# current symlink. Until the first such deploy, current points at workingDir.
{ siteCfg }:
let
  dir = siteCfg.workingDir;
  owner = "${siteCfg.user} ${siteCfg.user}";
in
if siteCfg.releases.enable then
  [
    "d ${dir}/releases 0750 ${owner} -"
    "d ${siteCfg.sharedDir} 0750 ${owner} -"
    # Only created when missing, so a switched link is never overwritten.
    "L ${dir}/current - - - - ."
  ]
else
  [ ]

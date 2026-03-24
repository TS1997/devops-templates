# Laravel Devenv Template

To install this template, run

`mkdir my-project`

`cd my-project`

`nix flake init --template "git+ssh://git@bitbucket.org/bravomedia/templates#laravel"`


Then you'll want to configure siteName and siteSlug in devenv.nix.
After that you need to start Devenv before installing Laravel


`devenv up`

Then to install laravel, you either do it manually using `laravel new`, or a simplified version running the script in devenv.nix;

`laravel-init`

Then you should be good to go!

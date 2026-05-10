# Flake Templates

## Usage

To create a new project in the directory `new-project` from the WordPress template:

```sh
mkdir new-project
cd new-project
nix flake init --refresh --template "github:ts1997/devops-templates?ref=master#wp-flake"
```

To create a Braavos base WordPress project:

```sh
mkdir new-project
cd new-project
nix flake init --refresh --template "github:ts1997/devops-templates?ref=master#wp-base"
```

To create a new Laravel site:

```sh
nix run "github:ts1997/devops-templates?ref=master#laravel-site"
```

To create a new Laravel package:

```sh
nix run "github:ts1997/devops-templates?ref=master#laravel-package"
```

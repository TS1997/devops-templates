# Flake Templates

## Usage

To create a new project in the directory `new-project` from the template.
`wp-flake`:

```sh
mkdir new-project
cd new-project
```

To create at Wordpress project.

```sh

nix flake init --refresh --template "github:ts1997/devops-templates?ref=master#wp-flake"
```

To create at Braavos base wp project.

```sh
nix flake init --refresh --template "github:ts1997/devops-templates?ref=master#wp-base"
``

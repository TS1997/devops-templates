# Devenv WordPress Bedrock-ish Template

## Description

This template sets up a development environment for WordPress using Bedrock. Bedrock is a WordPress boilerplate that helps you manage your WordPress site with modern development tools and practices. It provides a better project structure, improved security, and dependency management via Composer.

## Bedrock Structure

The Bravomedia Bedrock-ish structure organizes your WordPress project as follows:

- `packages/`: Project Custom Development
- - `mu-plugins/`: Custom developed mu-plugins
- - `plugins/`: Custom developed plugins
- - `themes/`: Custom developed themes
- `public/`: Web root folder
- `config/`: Configuration files for different environments (e.g., development, staging, production).

## The create-{plugin/theme} script

To get working with custom development, use the `composer run create-theme`, `composer run create-plugin` or `composer run create-module` to install new boilerplate themes, plugins or Braavos modules.

## Installation

The development environment is based on Nix, Devenv and Direnv.

#### Install Nix & Devenv
Read the getting started guide at https://devenv.sh/getting-started

#### Install Direnv (optional but recommended)
As non-root user do the following:

```sh
nix profile install nixpkgs#nix-direnv
```

Then add nix-direnv to `$HOME/.config/direnv/direnvrc`:

```sh
source $HOME/.nix-profile/share/nix-direnv/direnvrc
```

### Install composer dependecies
To run the application you need to install all PHP Compser dependencies

```sh
composer install
```

### Build assets
First, setup package.json in the root folder to build themes and plugins from root.
e.g:

```json
{
    "scripts" : {
        "build-essos": "cd ./packages/themes/essos && npm install",
        "build": "npm run build-essos",
        "prune-essos": "cd ./packages/themes/essos && npm prune --omit=dev",
        "prune": "npm run prune-essos",
        "postinstall": "npm run build && npm run prepare",
    }
}
```

Then, depending on the setup, use the following command to build:

```sh
npm install
```

## Copying predefined assets and db
```sh
Init-assets
```
This script copies images from the data/uploads directory to public/content/uploads.

```sh
reset-db
```
This script resets the server database and executes the database file.

## Starting Local Services

Services declared in `devenv.nix` can be started and managed with:

```sh
devenv up
```

More info on how [`devenv` works](https://devenv.sh/basics/).

## The Packages Folder Explained
All custom development for WordPress is put as seperate composer packages in the packages-folder.
All plugins, mu-plugins and themes must include a composer.json file that specifies `name` (eg. bravomedia/plugin-name) and `type` as either wordpress-plugin, wordpress-theme or wordpress-muplugin.

Then use composer Require to install the said package into WordPress:
```sh
composer require bravomedia/plugin-name @dev
```

`@dev` specifies the version to the git repository.

## License

GPLv2


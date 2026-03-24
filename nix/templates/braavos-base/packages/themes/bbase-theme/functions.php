<?php
/**
 * Functions and definitions for the BbaseTheme WordPress theme.
 *
 * This file runs the main theme function that utilizes all the hooks and filters
 *
 * @package BbaseTheme
 */

use Bravomedia\BbaseTheme\Theme;

// If this file is called directly, abort.
if ( ! defined( 'WPINC' ) ) {
	die;
}

/**
 * Currently plugin version.
 * Start at version 1.0.0 and use SemVer - https://semver.org
 * Rename this for your plugin and update it as you release new versions.
 */
define( 'BBASE_THEME_VERSION', '1.0.0' );

/**
 * The core plugin class that is used to define internationalization,
 * admin-specific hooks, and public-facing site hooks.
 */
require get_template_directory() . '/includes/class-theme.php';

/**
 * Begins execution of the plugin.
 *
 * Since everything within the plugin is registered via hooks,
 * then kicking off the plugin from this point in the file does
 * not affect the page life cycle.
 *
 * @since    1.0.0
 */
function run_bbasetheme_theme() {

	$theme = new Theme();
	return $theme->run();
}
global $bbasetheme_theme;
$bbasetheme_theme = run_bbasetheme_theme();

<?php
/**
 * Define the internationalization functionality
 *
 * Loads and defines the internationalization files for this plugin
 * so that it is ready for translation.
 *
 * @link       https://www.bravomedia.se
 * @since      1.0.0
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */

namespace Bravomedia\BbaseTheme;

/**
 * Define the internationalization functionality.
 *
 * Loads and defines the internationalization files for this plugin
 * so that it is ready for translation.
 *
 * @since      1.0.0
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 * @author     Bravomedia AB <support@bravomedia.se>
 */
class I18n {


	/**
	 * Load the plugin text domain for translation.
	 *
	 * @since    1.0.0
	 */
	public function load_theme_textdomain() {

		load_theme_textdomain(
			'bbase-theme',
			get_template_directory() . '/languages/'
		);
	}
}

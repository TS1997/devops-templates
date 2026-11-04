<?php
/**
 * The admin-specific functionality of the plugin.
 *
 * @link       https://www.bravomedia.se
 * @since      1.0.0
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */

namespace Bravomedia\BbaseTheme;

/**
 * The admin-specific functionality of the plugin.
 *
 * Defines the plugin name, version, and two examples hooks for how to
 * enqueue the admin-specific stylesheet and JavaScript.
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/setup
 * @author     Bravomedia AB <support@bravomedia.se>
 */
class Admin {
	/**
	 * The ID of this theme.
	 *
	 * @since    1.0.0
	 * @access   private
	 * @var      string    $theme_name    The ID of this theme.
	 */
	private $theme_name;

	/**
	 * The version of this theme.
	 *
	 * @since    1.0.0
	 * @access   private
	 * @var      string    $version    The current version of this theme.
	 */
	private $version;

	/**
	 * Initialize the class and set its properties.
	 *
	 * @since    1.0.0
	 * @param      string $theme_name       The name of this theme.
	 * @param      string $version    The version of this theme.
	 */
	public function __construct( $theme_name, $version ) {

		$this->theme_name = $theme_name;
		$this->version    = $version;
	}

	/**
	 * Register admin scripts
	 */
	public function limit_menu_depth() {
		wp_enqueue_script( 'bbase-theme-admin', get_template_directory_uri() . '/assets/build/admin.js', array(), filemtime( get_template_directory() . '/assets/build/admin.js' ), true );
		/**
		 * Set menu depth for each menu location
		 * 0 = only root level
		 */
		wp_add_inline_script(
			'bbase-theme-admin',
			sprintf(
				'var themeMenuDepth = %s',
				wp_json_encode(
					array(
						'header_secondary' => 0,
						'footer_1'         => 0,
						'footer_2'         => 0,
					)
				)
			),
			'before'
		);
	}
}

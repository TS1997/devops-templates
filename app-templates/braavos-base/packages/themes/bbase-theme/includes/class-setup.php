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
class Setup {

	/**
	 * The ID of this theme.
	 *
	 * @since    1.0.0
	 * @access   private
	 * @var      string    $theme_name    The ID of this theme.
	 */
	private $theme_name;

	/**
	 * The Assets method
	 *
	 * @since   1.0.0
	 * @access  public
	 * @var     Assets
	 */
	public $assets;

	/**
	 * Initialize the class and set its properties.
	 *
	 * @since    1.0.0
	 * @param      string $theme_name       The name of this theme.
	 */
	public function __construct( $theme_name ) {

		$this->theme_name = $theme_name;
		$this->assets     = new Assets();
	}

	/**
	 * Register ACF JSON save paths
	 * Set bbase-theme as ACF field group description to save json in plugin dir
	 *
	 * @since 1.0.0
	 *
	 * @param array $paths     The existing save paths.
	 * @param array $field_group The field group being saved.
	 * @return array Modified save paths.
	 */
	public function acf_json_save_paths( $paths, $field_group ) {

		if ( isset( $field_group['description'] ) && str_contains( $field_group['description'], $this->theme_name ) ) {
			$paths = array( get_template_directory() . '/acf-json' );
		}

		return $paths;
	}

	/**
	 * ACF JSON name rewrite
	 * Save the json-files with prefix
	 *
	 * @since 1.0.0
	 *
	 * @param string $filename   The original filename.
	 * @param array  $field_group The field group being saved.
	 * @return string Modified filename.
	 */
	public function acf_json_filename( $filename, $field_group ) {

		if ( isset( $field_group['description'] ) && str_contains( $field_group['description'], $this->theme_name ) ) {
			$filename = strtolower( sprintf( '%s_%s.json', $this->theme_name, str_replace( 'group_', '', $field_group['key'] ) ) );
		}

		return $filename;
	}

	/**
	 * Loads json files from plugin acf-json path
	 *
	 * @since 1.0.0
	 *
	 * @param array $paths The existing load paths.
	 * @return array Modified load paths.
	 */
	public function acf_json_load_point( $paths ) {

		$paths[] = get_template_directory() . '/acf-json';

		return $paths;
	}

	/**
	 * Login logo
	 *
	 * @since 1.0.0
	 */
	public function login_logo() {

		get_template_part( 'template-parts/utilities/login-logo' );
	}

	/**
	 * Login logo
	 *
	 * @since 1.0.0
	 */
	public function fonts() {

		get_template_part( 'template-parts/utilities/fonts' );
	}

	/**
	 * Theme supports
	 *
	 * @since 1.0.0
	 */
	public function theme_supports() {

		add_theme_support( 'html5', array( 'comment-list', 'comment-form', 'search-form', 'gallery', 'caption', 'style', 'script' ) );
		add_theme_support( 'align-wide' );
		add_theme_support( 'post-thumbnails' );
		add_theme_support( 'title-tag' );
	}

	/**
	 * Load theme styles
	 *
	 * @since 1.0.0
	 */
	public function load_theme_styles() {

		$this->assets->enqueue_style(
			$this->theme_name,
			'/assets/build/bbase-theme.css'
		);

		$this->assets->add_editor_style(
			'/assets/build/editor.css'
		);
	}

	/**
	 * Load theme scripts
	 *
	 * @since 1.0.0
	 */
	public function load_theme_scripts() {

		$this->assets->enqueue_script(
			$this->theme_name,
			'/assets/build/bbase-theme.js'
		);
	}

	/**
	 * Register theme menus
	 *
	 * @since 1.0.0
	 */
	public function register_theme_menus() {

		register_nav_menus(
			array(
				'header_primary'   => __( 'Primary Menu', 'bbase-theme' ),
				'header_secondary' => __( 'Secondary Menu', 'bbase-theme' ),
				'footer_1'         => __( 'Footer Menu 1', 'bbase-theme' ),
				'footer_2'         => __( 'Footer Menu 2', 'bbase-theme' ),
				'social'           => __( 'Social Media', 'bbase-theme' ),
			)
		);
	}

	/**
	 * Outputs the primary navigation menu.
	 *
	 * This function is responsible for rendering the primary navigation
	 * menu on the website. It retrieves the necessary menu items and
	 * generates the HTML output for the navigation. Ads the secondary
	 * navigation to the primary navigation for mobile devices.
	 *
	 * @return void
	 */
	public function primary_navigation_output() {

		if ( has_nav_menu( 'header_secondary' ) ) {

			$secondary = wp_nav_menu(
				array(
					'theme_location' => 'header_secondary',
					'menu_class'     => 'site-navigation__secondary',
					'menu_id'        => 'secondary-nav',
					'depth'          => 0, // Allow nested navigation for mobile secondary navigation.
					'container'      => false,
					'items_wrap'     => '<span id="%1$s" class="%2$s site-navigation__inner">%3$s</span>',
					'echo'           => false,
					'walker'         => new Nav_Menu(),
				)
			);

		} else {

			$secondary = '';

		}

		if ( has_nav_menu( 'header_primary' ) ) {

			$primary = wp_nav_menu(
				array(
					'theme_location' => 'header_primary',
					'menu_class'     => 'site-navigation__primary',
					'menu_id'        => 'primary-nav',
					'container'      => '',
					'echo'           => false,
					'items_wrap'     => '<ul id="%1$s" class="%2$s"><span class="site-navigation__inner">%3$s</span>' . ( $secondary ?? '' ) . '</ul>',
					'walker'         => new Nav_Menu(),
				)
			);

		} else {

			$primary = sprintf( '<ul id="%3$s" class="%2$s">%1$s</ul>', $secondary, 'site-navigation__primary', 'primary-nav' );

		}

		echo wp_kses_post( $primary );
	}

	/**
	 * Remove default post types from admin menu
	 *
	 * @since 1.0.0
	 */
	public function remove_post_admin_menus() {
    	remove_menu_page( 'edit.php' );
	}

	/**
	 * Remove default post types from admin toolbar
	 *
	 * @since 1.0.0
	 */

	public function remove_post_toolbar_menus() {
		global $wp_admin_bar;
		$wp_admin_bar->remove_menu( 'new-post' );
	}


	/**
	 * Create ACF Options Page for footer
	 *
	 * @since    1.0.0
	 */
	public function register_acf_global_settings_page() {
		if ( function_exists( 'acf_add_options_page' ) ) {
			acf_add_options_page(
				array(
					'page_title' => 'Globala inställningar',
					'menu_title' => 'Globala inställningar',
					'menu_slug'  => 'global-settings',
					'capability' => 'edit_posts',
				)
			);
		}
	}
}


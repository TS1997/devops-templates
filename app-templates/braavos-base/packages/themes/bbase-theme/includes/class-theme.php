<?php
/**
 * BbaseTheme Theme
 *
 * @package BbaseTheme
 */

namespace Bravomedia\BbaseTheme;

/**
 * The core plugin class.
 *
 * This is used to define internationalization, admin-specific hooks, and
 * public-facing site hooks.
 *
 * Also maintains the unique identifier of this plugin as well as the current
 * version of the plugin.
 *
 * @since      1.0.0
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 * @author     Bravomedia AB <support@bravomedia.se>
 */
class Theme {

	/**
	 * The loader that's responsible for maintaining and registering all hooks that power
	 * the plugin.
	 *
	 * @since    1.0.0
	 * @access   protected
	 * @var      Loader    $loader    Maintains and registers all hooks for the plugin.
	 */
	protected $loader;

	/**
	 * The unique identifier of this theme.
	 *
	 * @since    1.0.0
	 * @access   protected
	 * @var      string    $theme_name    The string used to uniquely identify this theme.
	 */
	protected $theme_name;

	/**
	 * The current version of the plugin.
	 *
	 * @since    1.0.0
	 * @access   protected
	 * @var      string    $version    The current version of the plugin.
	 */
	protected $version;

	/**
	 * The theme Setup instance
	 *
	 * @since   1.0.0
	 * @access  public
	 * @var     Setup   $setup      The Theme Setup instance
	 */
	public $setup;

	/**
	 * The theme Braavos instance
	 *
	 * @since   1.0.0
	 * @access  public
	 * @var     Braavos $braavos    The Theme Braavos instance
	 */
	public $braavos;

	/**
	 * The theme Admin instance
	 *
	 * @since   1.0.0
	 * @access  public
	 * @var     Admin   $admin  The Theme admin instance
	 */
	public $admin;

	/**
	 * Define the core functionality of the plugin.
	 *
	 * Set the plugin name and the plugin version that can be used throughout the plugin.
	 * Load the dependencies, define the locale, and set the hooks for the admin area and
	 * the public-facing side of the site.
	 *
	 * @since    1.0.0
	 */
	public function __construct() {
		if ( defined( 'BBASE_THEME_VERSION' ) ) {
			$this->version = BBASE_THEME_VERSION;
		} else {
			$this->version = '1.0.0';
		}
		$this->theme_name = 'bbase-theme';

		$this->load_dependencies();
		$this->set_locale();
		$this->define_setup_hooks();
		$this->define_braavos_hooks();
		$this->define_admin_hooks();
	}

	/**
	 * Load the required dependencies for this theme.
	 *
	 * Include the following files that make up the plugin:
	 *
	 * - Loader. Orchestrates the hooks of the plugin.
	 * - i18n. Defines internationalization functionality.
	 * - Admin. Defines all hooks for the admin area.
	 * - Public. Defines all hooks for the public side of the site.
	 *
	 * Create an instance of the loader which will be used to register the hooks
	 * with WordPress.
	 *
	 * @since    1.0.0
	 * @access   private
	 */
	private function load_dependencies() {

		/**
		 * A helper class for including assets with version numbers
		 */
		require_once get_template_directory() . '/includes/class-assets.php';

		/**
		 * The class responsible for orchestrating the actions and filters of the
		 * core plugin.
		 */
		require_once get_template_directory() . '/includes/class-loader.php';

		/**
		 * The class responsible for defining internationalization functionality
		 * of the plugin.
		 */
		require_once get_template_directory() . '/includes/class-i18n.php';

		/**
		 * Registers the custom nav menu walker
		 */
		require_once get_template_directory() . '/includes/class-nav-menu.php';

		/**
		 * The class responsible for defining all actions that occur in the admin area.
		 */
		require_once get_template_directory() . '/includes/class-admin.php';

		/**
		 * The class responsible for defining all actions that occur during theme setup.
		 */
		require_once get_template_directory() . '/includes/class-setup.php';

		/**
		 * The class responsible for defining all actions responsible for image sizes.
		 */
		require_once get_template_directory() . '/includes/class-images.php';

		new Images( $this->get_theme_name() );

		/**
		 * The class responsible for defining all actions that occur in the Braavos modules.
		 */
		require_once get_template_directory() . '/includes/class-braavos.php';

		$this->loader = new Loader();
	}

	/**
	 * Define the locale for this plugin for internationalization.
	 *
	 * Uses the i18n class in order to set the domain and to register the hook
	 * with WordPress.
	 *
	 * @since    1.0.0
	 * @access   private
	 */
	private function set_locale() {

		$theme_i18n = new I18n();

		$this->loader->add_action( 'after_setup_theme', $theme_i18n, 'load_theme_textdomain' );
	}

	/**
	 * Register all of the hooks that occur during theme setup.
	 * of the plugin.
	 *
	 * @since    1.0.0
	 * @access   private
	 */
	private function define_setup_hooks() {

		$this->setup = new Setup( $this->get_theme_name(), $this->get_version() );

		// ACF JSON Setup.
		$this->loader->add_filter( 'acf/json/save_paths', $this->setup, 'acf_json_save_paths', 10, 2 );
		$this->loader->add_filter( 'acf/json/save_file_name', $this->setup, 'acf_json_filename', 10, 3 );
		$this->loader->add_filter( 'acf/settings/load_json', $this->setup, 'acf_json_load_point' );

		// Scripts & Styles.
		$this->loader->add_action( 'wp_head', $this->setup, 'fonts' );
		$this->loader->add_filter( 'init', $this->setup, 'load_theme_styles' );
		$this->loader->add_filter( 'init', $this->setup, 'load_theme_scripts' );

		// Admin branding.
		$this->loader->add_action( 'login_head', $this->setup, 'login_logo' );

		// Admin branding.
		$this->loader->add_action( 'login_head', $this->setup, 'login_logo' );

		//remove default post types from admin menu
		$this->loader->add_action( 'admin_menu', $this->setup, 'remove_post_admin_menus' );

		//remove default post types from admin toolbar
		$this->loader->add_action( 'wp_before_admin_bar_render', $this->setup, 'remove_post_toolbar_menus' );

		// ACF Global Theme Settings page.
		$this->loader->add_action( 'acf/init', $this->setup, 'register_acf_global_settings_page' );

		// $this->loader->add_filter( 'acf/fields/wysiwyg/toolbars', $this->braavos, 'change_wysiwyg_toolbar' );

		// Nav menus.
		$this->loader->add_action( 'after_setup_theme', $this->setup, 'register_theme_menus' );
		$this->loader->add_action( 'after_setup_theme', $this->setup, 'theme_supports' );
		$this->loader->add_action( 'theme_primary_navigation', $this->setup, 'primary_navigation_output' );
	}

	/**
	 * Register all of the hooks related to the public-facing functionality
	 * of the plugin.
	 *
	 * @since    1.0.0
	 * @access   private
	 */
	private function define_braavos_hooks() {

		$this->braavos = new Braavos( $this->get_theme_name(), $this->get_version() );

		$this->loader->add_filter( 'braavos/field_group/default/supported_post_types', $this->braavos, 'supported_post_types' );
		$this->loader->add_filter( 'braavos/field_group/default/supported_templates_page', $this->braavos, 'supported_templates_page' );
		$this->loader->add_filter( 'braavos/module/posts/content_types', $this->braavos, 'posts_content_types', 10 );
		$this->loader->add_filter( 'braavos/module/settings', $this->braavos, 'module_theme_setting', 10, 2 );
		$this->loader->add_filter( 'braavos/module/settings', $this->braavos, 'module_width_setting', 10, 2 );
		$this->loader->add_filter( 'braavos/module/settings', $this->braavos, 'module_layout_setting', 10, 2 );
		$this->loader->add_filter( 'braavos/module/settings', $this->braavos, 'content_position_setting', 10, 2 );
		$this->loader->add_filter( 'braavos/module/settings', $this->braavos, 'item_layout_setting', 10, 2 );
		$this->loader->add_filter( 'braavos/module/hero/acf/content', $this->braavos, 'override_hero_content_field', 10, 2 );
		$this->loader->add_filter( 'braavos/module/media_content/acf/content', $this->braavos, 'override_media_content_content_field', 10, 2 );
		$this->loader->add_filter( 'braavos/modules/posts/swiper_config', $this->braavos, 'posts_swiper_config', 10, 2 );
		$this->loader->add_filter( 'braavos/module/posts_post/fields', $this->braavos, 'posts_link_field', 10, 2 );
		$this->loader->add_filter( 'braavos/modules/posts/frontend/navigation_html', $this->braavos, 'posts_link_render', 10, 2 );

		$this->loader->add_action( 'after_setup_theme', $this->braavos, 'add_module_headline' );
		$this->loader->add_action( 'wp_enqueue_scripts', $this->braavos, 'remove_default_braavos_styles' );
		$this->loader->add_action( 'braavos/module/hero/frontend/foreground', $this->braavos, 'override_hero_content_render', 5, 1 );
		$this->loader->add_action( 'braavos/module/media_content/frontend/content', $this->braavos, 'override_media_content_content_render', 5, 1 );
		$this->loader->add_filter( 'braavos/module/posts/frontend/single/readmore', $this->braavos, 'braavos_posts_readmore', 10, 3 );
		$this->loader->add_filter( 'braavos/module/wysiwyg/content/toolbar', $this->braavos, 'change_wysiwyg_toolbar', 10 );

	}

	/**
	 * Register all of the hooks related to the admin-facing functionality
	 * of the plugin.
	 *
	 * @since    1.0.0
	 * @access   private
	 */
	private function define_admin_hooks() {
		$this->admin = new Admin( $this->get_theme_name(), $this->get_version() );
		$this->loader->add_action( 'admin_enqueue_scripts', $this->admin, 'limit_menu_depth' );
	}

	/**
	 * Run the loader to execute all of the hooks with WordPress.
	 *
	 * @since    1.0.0
	 */
	public function run() {
		$this->loader->run();
	}

	/**
	 * The name of the plugin used to uniquely identify it within the context of
	 * WordPress and to define internationalization functionality.
	 *
	 * @since     1.0.0
	 * @return    string    The name of the plugin.
	 */
	public function get_theme_name() {
		return $this->theme_name;
	}

	/**
	 * The reference to the class that orchestrates the hooks with the plugin.
	 *
	 * @since     1.0.0
	 * @return    Loader    Orchestrates the hooks of the plugin.
	 */
	public function get_loader() {
		return $this->loader;
	}

	/**
	 * Retrieve the version number of the plugin.
	 *
	 * @since     1.0.0
	 * @return    string    The version number of the plugin.
	 */
	public function get_version() {
		return $this->version;
	}
}

<?php
/**
 * The public-facing functionality of the plugin.
 *
 * @link       https://www.bravomedia.se
 * @since      1.0.0
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */

namespace Bravomedia\BbaseTheme;

/**
 * The public-facing functionality of the plugin.
 *
 * Defines the plugin name, version, and two examples hooks for how to
 * enqueue the public-facing stylesheet and JavaScript.
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 * @author     Bravomedia AB <support@bravomedia.se>
 */
class Braavos {

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
	 * @param      string $theme_name       The name of the plugin.
	 * @param      string $version    The version of this theme.
	 */
	public function __construct( $theme_name, $version ) {

		$this->theme_name = $theme_name;
		$this->version    = $version;
	}

	/**
	 * Setup which post types to use Braavos on
	 *
	 * @param array $post_types Defaults to ['page'].
	 */
	public function supported_post_types( array $post_types ) {

		return $post_types;
	}

	/**
	 * Setup which page templates for post type "Page" to use with Braavos
	 *
	 * @param array $templates Defaults to empty array (Use with all templates).
	 */
	public function supported_templates_page( array $templates ) {
		$templates[] = 'page-landing.php';
		return $templates;
	}

	/**
	 * Setup Posts-module content types
	 *
	 * @param array $content_types and array of content types.
	 */
	public function posts_content_types( array $content_types ) {
		/**
		 * Returns array of post types and settings.
		 *
		 * E.g: array( 'module_slug' => array( 'post_type' => 'page', 'filter' => 'pick_post' ,'label' => __('Module Name'), 'icon' => '\f105', 'color' => '#E7EFC5' ) )
		 * 'filter' is the fields that are rendered in the admin interface of the module. Default filters are 'pick_post' and 'category'
		 * where 'pick_post' uses a post_object field to generate and array of post objects.
		 * 'category' is a category field in the admin interface of the module, and uses WP_Query 'category' to retreive those posts.
		 *
		 * Add a custom filter via the 'braavos/module/posts/{module_slug}/filter/fields' filter.
		 * Accepts 2 arguments: array of fields, and the module object.
		 * E.g: use $module->filter == 'your_filter' to add a new filter for your posts module.
		 *
		 * The use the 'braavos/module/posts/frontend/posts' filter to setup the WP_Query based on your filter.
		 * Accepts 3 arguments: $posts, $raw_content and $module. Returns an array of post objects.
		 *
		 * eg: unset( $content_types['page'] );
		 */

		return $content_types;
	}

	/**
	 * Remove default braavos styles
	 *
	 * @return void
	 */
	public function remove_default_braavos_styles() {
		wp_deregister_style( 'braavos' );
		wp_deregister_style( 'braavos-hero' );
		wp_deregister_style( 'braavos-media_content' );
		wp_deregister_style( 'braavos-columns' );
		wp_deregister_style( 'braavos-posts' );
	}

	/**
	 * Set module theme setting
	 *
	 * @param array  $settings The settings array.
	 * @param Module $module The Braavos Module.
	 * @return array
	 */
	public function module_theme_setting( $settings, $module ) {

		if ( ! $module ) {
			return $settings;
		}

		$choices = array(
			'none'      => __( 'Transparent', 'bbase-theme' ),
			'primary'   => __( 'Primary', 'bbase-theme' ),
			'grey'  => __( 'Grey ', 'bbase-theme' ),
		);

		if ( ! isset( $settings['module-theme'] ) ) {
			$new_settings = array(
				'module-theme' => array(
					'type'          => 'button_group',
					'label'         => __( 'Module theme', 'bbase-theme' ),
					'choices'       => $choices,
					'default_value' => 'none',
				),
			);
			$settings     = array_merge( $new_settings, $settings );
		} else {
			$settings['module-theme']['choices']       = $choices;
			$settings['module-theme']['default_value'] = 'none';
		}

		return $settings;
	}

	/**
	 * Set module width setting
	 *
	 * @param array  $settings The settings array.
	 * @param Module $module The Braavos Module.
	 */
	public function module_width_setting( $settings, $module ) {
		if ( ! isset( $settings['module-width'] ) ) {
			return $settings;
		}

		switch ( $module->name ) :

			case 'hero':
			case 'media_content':
			case 'wysiwyg':
				unset( $settings['module-width']['choices']['grid'] );
				break;
			default:
				unset( $settings['module-width']['choices']['full'] );
				break;

		endswitch;

		return $settings;
	}

	/**
	 * Set module width setting
	 *
	 * @param array  $settings The settings array.
	 * @param Module $module The Braavos Module.
	 */
	public function content_position_setting( $settings, $module ) {
		if ( ! isset( $settings['content-position'] ) ) {
			return $settings;
		}

		switch ( $module->name ) :

			case 'media_content':
				break;
			default:
				unset( $settings['content-position'] );
				break;

		endswitch;

		return $settings;
	}

	/**
	 * Set Module Layout settings
	 *
	 * @param array  $settings The settings array.
	 * @param Module $module The Braavos Module.
	 */
	public function module_layout_setting( $settings, $module ) {
		if ( ! isset( $settings['module-layout'] ) ) {
			return $settings;
		}
		switch ( $module->name ) :
			case 'posts_post':
				$settings['module-layout']['choices'] = array( 'slider' => 'Slider' );
				break;
			case 'posts_page':
				$settings['module-layout']['choices'] = array( 'grid' => 'Grid' );
				break;
			case 'columns':
				$settings['module-layout']['choices'] = array( 'grid' => 'Grid' );
				break;
		endswitch;

		return $settings;
	}

	/**
	 * Set Module Layout settings
	 *
	 * @param array  $settings The settings array.
	 * @param Module $module The Braavos Module.
	 */
	public function item_layout_setting( $settings, $module ) {
		if ( ! $module ) {
			return $settings;
		}
		if ( ! isset( $settings['item-layout'] ) ) {
			return $settings;
		}

		if ( isset( $settings['item-layout']['choices']['banner'] ) ) {
			unset( $settings['item-layout']['choices']['banner'] );
		}

		return $settings;
	}

	/**
	 * Add module headline
	 */
	public function add_module_headline() {
		// Columns Module.
		add_filter( 'braavos/module/columns/heading/enabled', '__return_true' );
		// Posts Module.
		add_filter( 'braavos/module/posts_post/heading/enabled', '__return_true' );
	}

	/**
	 * Customize Braavos Hero module content field for seperated fields
	 *
	 * @param Array  $field Content field array.
	 * @param Module $module The Braavos Module.
	 * @return Array $field
	 */
	public function override_hero_content_field( $field, $module ) {

		$field = array(
			'key'          => $module->field_key . 'content_fields',
			'type'         => 'clone',
			'wrapper'      => array(
				'width' => '',
				'class' => '',
				'id'    => '',
			),
			'clone'        => array(
				// The Hero Content Field Group.
				0 => 'group_663a2fb472de7',
			),
			'display'      => 'seamless',
			'prefix_label' => 0,
			'prefix_name'  => 0,
		);

		return $field;
	}

	/**
	 * Customize Braavos Hero module content field for separated content fields
	 */
	public function override_hero_content_render() {
		remove_action( 'braavos/module/hero/frontend/foreground', 'Bravomedia\Braavos\module_hero_render_foreground', 10 );
		add_action( 'braavos/module/hero/frontend/foreground', array( $this, 'override_hero_content_cb' ), 15, 1 );
	}

	/**
	 * Render Braavos Hero separated content fields
	 *
	 * @param Module $module The Braavos Module.
	 */
	public function override_hero_content_cb( $module ) {
		get_template_part( 'template-parts/braavos/hero', 'content', $module->raw_content );
	}

	/**
	 * Customize Braavos Media / Content module content field for seperated fields
	 *
	 * @param Array  $field Content field array.
	 * @param Module $module The Braavos Module.
	 * @return Array $field
	 */
	public function override_media_content_content_field( $field, $module ) {

		$field = array(
			'key'          => $module->field_key . 'content_fields',
			'type'         => 'clone',
			'wrapper'      => array(
				'width' => '',
				'class' => '',
				'id'    => '',
			),
			'clone'        => array(
				// The Media Content Content Field Group.
				0 => 'group_6641dc74d49b5',
			),
			'display'      => 'seamless',
			'prefix_label' => 0,
			'prefix_name'  => 0,
		);

		return $field;
	}

	/**
	 * Customize Braavos Media / Content module content field for separated content fields
	 */
	public function override_media_content_content_render() {

		remove_action( 'braavos/module/media_content/frontend/content', 'Bravomedia\Braavos\module_media_content_render_content', 10 );
		add_action( 'braavos/module/media_content/frontend/content', array( $this, 'override_media_content_content_cb' ), 15, 1 );
	}

	/**
	 * Render Braavos Media / Content separated content fields
	 *
	 * @param Module $module The Braavos Module.
	 */
	public function override_media_content_content_cb( $module ) {
		get_template_part( 'template-parts/braavos/media_content', 'content', $module->raw_content );
	}

	/**
	 * Swiper slideshow configuration remove navigation arrows and autoplay.
	 *
	 * @param array $config The Swiper Config.
	 * @return Array
	 */
	public function posts_swiper_config( $config ) {
		$config['loop']                                    = false;
		$config['pagination']                              = false;
		$config['navigation']                              = array(
			'nextEl' => '.swiper-button-next',
			'prevEl' => '.swiper-button-prev',
		);
		$config['autoplay']                                = false;
		$config['slidesOffsetBefore']                      = 24;
		$config['spaceBetween']                            = 24;
		$config['breakpoints'][768]['slidesOffsetBefore']  = 32;
		$config['breakpoints'][768]['slidesPerView']       = 'auto';
		$config['breakpoints'][1024]['slidesOffsetBefore'] = 0;
		$config['breakpoints'][1440]                       = $config['breakpoints'][1024];
		$config['breakpoints'][1440]['slidesOffsetBefore'] = 0;

		return $config;
	}

	/**
	 * Add a Link field to add a link to the module
	 *
	 * @param array  $fields The fields array.
	 * @param Module $module The Braavos Module.
	 */
	public function posts_link_field( $fields, $module ) {
		$fields[] = array(
			'key'           => $module->field_key,
			'label'         => __( 'Call to action', 'bbase-theme' ),
			'name'          => 'link',
			'type'          => 'link',
			'return_format' => 'array',
		);
		return $fields;
	}

	/**
	 * Add a module footer to posts module
	 *
	 * @param string $html   The module HTML.
	 * @param Module $module The Braavos Module.
	 */
	public function posts_link_render( $html, $module ) {
		if ( 'posts_post' !== $module->name ) {
			return $html;
		}

		$link = false;

		if ( isset( $module->raw_content['link'] ) ) {
			$link = $module->raw_content['link'];
		}

		ob_start();

		get_template_part(
			'template-parts/braavos/braavos',
			'posts-footer',
			array(
				'swiper-navigation' => $html,
				'link'              => $link,
			)
		);

		$html = ob_get_clean();

		return $html;
	}

	/**
	 * Braavos Posts read more link
	 * braavos/module/posts/frontend/single/readmore
	 */
	public function braavos_posts_readmore() {
		return __( 'Read more', 'bbase-theme' );
	}

	/**
	 * Change WYSIWYG toolbar for wysiwyg module
	 * braavos/module/wysiwyg/content/toolbar
	 */

	public function change_wysiwyg_toolbar( $toolbar ) {
		return 'basic';
	}
}

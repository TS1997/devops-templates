<?php
/**
 * The file that defines the core class for handling images in the theme.
 *
 * @since      1.0.0
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */

namespace Bravomedia\BbaseTheme;

/**
 * The core class for handling images in the theme.
 *
 * @since      1.0.0
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */
class Images {

	/**
	 * The name of the theme.
	 *
	 * @since    1.0.0
	 * @access   private
	 * @var      string    $theme_name    The name of the theme.
	 */
	private $theme_name;

	/**
	 * The image sizes
	 *
	 * @since    1.0.0
	 * @access   private
	 * @var      string    $version    The version of the theme.
	 */
	private $image_sizes;

	/**
	 * The default settings for the image sizes
	 *
	 * @since    1.0.0
	 * @access   private
	 * @var      array    $version    The default values.
	 */
	private $image_default;

	/**
	 * Initialize the class and set its properties.
	 *
	 * @since    1.0.0
	 * @param      string $theme_name       The name of this theme.
	 */
	public function __construct( $theme_name ) {

		$this->theme_name = $theme_name;

		$this->image_default = array(
			'align' => 'center',
			'size'  => 'bbase-theme-content',
		);

		$this->image_sizes = array(
			'2-col'         => array( 'width' => 640 ), // 2-Column image.
			'3-col'         => array( 'width' => 464 ), // 3-Column image.
			'4-col'         => array( 'width' => 342 ), // 4-Column image.
			'content-small' => array( 'width' => 375 ), // iPhone width.
			'content'       => array(
				'width' => 768, // Content-width.
				'label' => __( 'Content width', 'bbase-theme' ),
			),
			'content-large' => array(
				'width' => 1280, // Max grid width.
				'label' => __( 'Grid width', 'bbase-theme' ),
			),
			'full-hd'       => array(
				'width' => 1920,
				'label' => __( 'Full HD', 'bbase-theme' ),
			),
			'2k'            => array(
				'width' => 2048,
				'label' => __( '2k', 'bbase-theme' ),
			),
			'4k'            => array(
				'width' => 3840,
				'label' => __( '4k', 'bbase-theme' ),
			),
		);

		$this->init_images();
	}


	/**
	 * Initialize image sizes.
	 *
	 * @return void
	 */
	public function init_images() {
		add_action( 'after_setup_theme', array( $this, 'add_image_sizes' ) );
		add_action( 'after_setup_theme', array( $this, 'default_image_options' ) );
		add_filter( 'image_size_names_choose', array( $this, 'readable_image_sizes' ) );
	}

	/**
	 * Add image sizes
	 *
	 * Smaller sizes default to retina, larger sizes ads retina as an fallback
	 *
	 * @since 1.0.0
	 */
	public function add_image_sizes() {

		foreach ( $this->image_sizes as $size_name => $values ) {
			add_image_size( sprintf( '%s-%s-@0.5x', $this->theme_name, $size_name ), $values['width'] / 2 );
			add_image_size( sprintf( '%s-%s', $this->theme_name, $size_name ), $values['width'] );
			add_image_size( sprintf( '%s-%s-@2x', $this->theme_name, $size_name ), $values['width'] * 2 );
			add_image_size( sprintf( '%s-%s-@3x', $this->theme_name, $size_name ), $values['width'] * 3 );
		}
	}

	/**
	 * Add readable image size name for WP Admin
	 *
	 * @since 1.0.0
	 *
	 * @param array $sizes The defined image sizes.
	 * @return array $sizes
	 */
	public function readable_image_sizes( $sizes ) {

		$labels = array();

		foreach ( $this->image_sizes as $size_name => $values ) {
			if ( isset( $values['label'] ) ) {
				$labels[ sprintf( '%s-%s', $this->theme_name, $size_name ) ] = $values['label'];
			}
		}

		$sizes = array_merge( $sizes, $labels );

		return $sizes;
	}

	/**
	 * Set default image sizes from the upload media box
	 */
	public function default_image_options() {
		// Set default values for the upload media box.
		update_option( 'image_default_align', $this->image_default['align'] );
		update_option( 'image_default_size', $this->image_default['size'] );
	}
}

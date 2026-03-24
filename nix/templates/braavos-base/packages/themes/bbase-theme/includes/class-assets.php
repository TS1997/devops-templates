<?php
/**
 * Assets Class
 *
 * @package BbaseTheme
 */

namespace Bravomedia\BbaseTheme;

/**
 * Helper class for handling asset versioning
 *
 * @link       https://www.bravomedia.se/
 * @since      1.0.0
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */
class Assets {

	/**
	 * If is path or uri
	 *
	 * @param string $src The source URL or path.
	 * @return bool True if the source is a path, false if it's a URI.
	 */
	private function is_path( $src ) {
		return ! filter_var( $src, FILTER_VALIDATE_URL, FILTER_FLAG_PATH_REQUIRED );
	}

	/**
	 * Get file version
	 *
	 * @param string $src The source URL or path.
	 * @return mixed The file version or false if not found.
	 */
	private function get_file_version( $src ) {

		if ( ! $this->is_path( $src ) ) {
			return false;
		}

		$file_path = get_template_directory() . $src;
		if ( file_exists( $file_path ) ) {
			$version = filemtime( $file_path );
			return $version;
		}

		return false;
	}

	/**
	 * Function to register scripts
	 *
	 * @param string      $type The type of asset (script or style).
	 * @param string      $handle The unique handle for the asset.
	 * @param string      $src The source URL or path of the asset.
	 * @param array       $deps An array of dependencies for the asset.
	 * @param string|bool $version The version number of the asset.
	 * @param array|bool  $other Additional arguments for the asset.
	 */
	private function register_asset( $type, $handle, $src, $deps = array(), $version = false, $other = false ) {

		$register_function = sprintf( '\wp_register_%s', $type );

		if ( $this->is_path( $src ) ) {

			$file_version = $this->get_file_version( $src );

			$src = get_template_directory_uri() . $src;

			if ( $file_version ) {
				$version = $file_version;
			}
		}

		$register_function( $handle, $src, $deps, $version, $other );
	}

	/**
	 * Register theme scripts with version number
	 *
	 * @param string      $handle The unique handle for the script.
	 * @param string      $src The source URL or path of the script.
	 * @param array       $deps An array of dependencies for the script.
	 * @param string|bool $version The version number of the script.
	 * @param array|bool  $args Additional arguments for the script.
	 */
	public function register_script( $handle, $src, $deps = array(), $version = false, $args = array() ) {
		$this->register_asset( 'script', $handle, $src, $deps, $version, $args );
	}

	/**
	 * Register theme scripts with version number
	 *
	 * @param string      $handle The unique handle for the script.
	 * @param string      $src The source URL or path of the script.
	 * @param array       $deps An array of dependencies for the script.
	 * @param string|bool $version The version number of the script.
	 * @param string      $media The media for which this stylesheet has been defined.
	 */
	public function register_style( $handle, $src, $deps = array(), $version = false, $media = 'all' ) {
		$this->register_asset( 'style', $handle, $src, $deps, $version, $media );
	}

	/**
	 * Function to enqueue scripts
	 *
	 * @param string      $handle The unique handle for the script.
	 * @param string      $src The source URL or path of the script.
	 * @param array       $deps An array of dependencies for the script.
	 * @param string|bool $version The version number of the script.
	 * @param array|bool  $args Additional arguments for the script.
	 */
	public function enqueue_script( $handle, $src = false, $deps = false, $version = false, $args = array() ) {
		if ( $src ) {
			$this->register_script( $handle, $src, $deps, $version, $args );
		}
		add_action(
			'wp_enqueue_scripts',
			function () use ( $handle ) {
				wp_enqueue_script( $handle );
			}
		);
	}

	/**
	 * Function to enqueue scripts
	 *
	 * @param string      $handle The unique handle for the script.
	 * @param string      $src The source URL or path of the script.
	 * @param array       $deps An array of dependencies for the script.
	 * @param string|bool $version The version number of the script.
	 * @param string      $media The media for which this stylesheet has been defined.
	 */
	public function enqueue_style( $handle, $src = false, $deps = false, $version = false, $media = 'all' ) {
		if ( $src ) {
			$this->register_style( $handle, $src, $deps, $version, $media );
		}
		add_action(
			'wp_enqueue_scripts',
			function () use ( $handle ) {
				wp_enqueue_style( $handle );
			}
		);
	}


	/**
	 * Add editor styles with versioning
	 *
	 * @param string $src The source URL or path of the editor style.
	 */
	public function add_editor_style( $src ) {

		if ( $this->is_path( $src ) ) {

			$file_version = $this->get_file_version( $src );

			$src = get_template_directory_uri() . $src;

			if ( $file_version ) {
				$src = sprintf( '%s?%s', $src, $file_version );
			}

			add_action(
				'admin_init',
				function () use ( $src ) {
					\add_editor_style( $src );
				}
			);

		}
	}
}

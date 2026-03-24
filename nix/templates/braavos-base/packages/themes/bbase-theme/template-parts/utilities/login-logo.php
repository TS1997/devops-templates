<?php
/**
 * Displays a logo on the wp-login.php screen
 *
 * @package BbaseTheme
 */

$logo_path = '/assets/images/logo.svg';

/**
 * Set location and filename for admin logo path, relative to the stylesheet directory
 *
 * @param   string    $logo_path     The path for the logo
 */
apply_filters( 'theme_admin_logo_path', $logo_path );


if ( ! file_exists( get_stylesheet_directory() . $logo_path ) ) {
	return;
}

$logo_size = array(
	'width'  => '312px',
	'height' => '100px',
);

/**
 * Set the size of the admin logo
 *
 * @param   array   $logo_size      The size of the logo
 */
apply_filters( 'theme_admin_logo_size', $logo_path );

$logo = get_stylesheet_directory_uri() . $logo_path;
?>

<style type="text/css">
	.login h1 a {
		background-image: url(<?php echo esc_url( $logo ); ?>);
		background-size: contain;
		background-repeat: no-repeat;
		background-position: center center;
		display: block;
		overflow: hidden;
		text-indent: -9999em;
		width: <?php echo esc_attr( $logo_size['width'] ); ?>;
		height: <?php echo esc_attr( $logo_size['height'] ); ?>;
	}
</style>
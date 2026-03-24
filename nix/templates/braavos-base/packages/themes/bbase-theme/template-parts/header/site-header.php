<?php
/**
 * Template part for displaying the site header
 *
 * @package BbaseTheme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}
?>

<header id="site-header" class="site-header">
	<div class="site-overlay"></div>
	<?php if ( file_exists( get_theme_file_path() . '/assets/images/logo.svg' ) ) : ?>
		<div class="site-header__branding">
			<a href="<?php echo esc_url( get_home_url() ); ?>">
				<img src="<?php printf( '%s/%s?%s', esc_url( get_theme_file_uri() ), '/assets/images/logo.svg', esc_attr( filemtime( get_theme_file_path() . '/assets/images/logo.svg' ) ) ); ?>" class="site-header__logo"/>
			</a>
		</div>
	<?php endif; ?>

	<nav class="site-navigation" itemscope="itemscope" itemtype="https://schema.org/SiteNavigationElement">
		<?php if ( has_nav_menu( 'header_secondary' ) ) : ?>
			<?php
			wp_nav_menu(
				array(
					'theme_location' => 'header_secondary',
					'menu_class'     => 'site-navigation__extra',
					'container'      => '',
					'menu_id'        => 'secondary-nav-extra',
					'depth'          => 1,
				)
			);
			?>
		<?php endif; ?>
		</a>
		<a href="#primary-nav" aria-controls="primary-nav" class="site-navigation__toggle">
			<span class="icon"><i></i><i></i><i></i></span>
		</a>
		<div class="site-navigation__container">
			<?php do_action( 'theme_primary_navigation' ); ?>
		</div>
	</nav><!-- /.site-navigation -->
</header><!-- #site-header -->

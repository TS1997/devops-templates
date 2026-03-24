<?php
/**
 * Template part for displaying the footer
 *
 * @package BbaseTheme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}
?>

<footer id="site-footer" class="site-footer">
	<div class="site-footer__container">
		<div class="site-footer__column site-footer__column--presentation">
			<?php if ( file_exists( get_theme_file_path() . '/assets/images/logo.svg' ) ) : ?>
				<figure class="site-footer__branding">
					<img src="<?php printf( '%s/%s?%s', esc_url( get_theme_file_uri() ), '/assets/images/logo-neg.svg', esc_attr( filemtime( get_theme_file_path() . '/assets/images/logo.svg' ) ) ); ?>" class="site-footer__logo"/>
					<figcaption><?php echo esc_html( get_bloginfo( 'description' ) ); ?></figcaption>
				</figure>
			<?php endif; ?>
		</div>
		<?php if ( has_nav_menu( 'footer_1' ) ) : ?>
			<div class="site-footer__column">
				<h3 class="site-footer__heading"><?php echo esc_html( wp_get_nav_menu_name( 'footer_1' ) ); ?></h3>
				<?php
					wp_nav_menu(
						array(
							'theme_location' => 'footer_1',
							'menu_id'        => 'footer_1-menu',
							'menu_class'     => 'site-footer__menu',
							'container'      => '',
						)
					);
				?>
			</div>
			<?php endif; ?>
			<?php $footer_contact = get_field( 'ft_text_contact', 'option' ); ?>
			<?php if ( $footer_contact ) : ?>
				<div class="site-footer__column">
					<?php echo wp_kses_post( $footer_contact ); ?>
				</div>
			<?php endif; ?>
			<?php $footer_about = get_field( 'ft_about', 'option' ); ?>
			<?php if ( $footer_about ) : ?>
				<div class="site-footer__column">
					<?php echo wp_kses_post( $footer_about ); ?>
				</div>
			<?php endif; ?>
		</div>
		<?php get_template_part( 'template-parts/footer/sub-footer' ); ?>
	</div>
</footer><!-- #site-footer -->

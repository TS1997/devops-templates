<?php
/**
 * Template part for displaying the sub-footer
 *
 * @package BbaseTheme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}
?>

<div class="sub-footer">
	<div class="sub-footer__container">
		<?php if ( has_nav_menu( 'social' ) ) : ?>
			<div class="site-footer__social">
				<?php
					wp_nav_menu(
						array(
							'theme_location' => 'social',
							'menu_id'        => 'social-menu',
							'menu_class'     => 'sub-footer__social-menu',
						)
					);
				?>
			</div>
		<?php endif; ?>
		<div class="sub-footer__copyright">
			<?php
				$dt = new DateTime( 'now', wp_timezone() );
				// translators: %1$s: Year, %2$s: Site name.
				printf( esc_html__( '&copy; Copyright %1$s %2$s', 'bbase-theme' ), esc_attr( $dt->format( 'Y' ) ), esc_html( get_bloginfo( 'name' ) ) );
			?>
		</div>
	</div>
</div>
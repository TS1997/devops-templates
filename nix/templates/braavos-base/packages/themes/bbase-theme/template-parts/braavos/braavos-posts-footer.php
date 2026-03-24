<?php
/**
 * Posts module footer template
 *
 * @package BbaseTheme
 */

?>

<div class="braavos-module-footer">
	<?php if ( $args['link'] ) : ?>
		<?php
		get_template_part(
			'template-parts/components/component',
			'link',
			array(
				'link'      => esc_url( $args['link'] ),
				'classname' => 'braavos-module-footer__link',
			)
		);
		?>
	<?php endif; ?>
	<?php echo wp_kses_post( $args['swiper-navigation'] ); ?>
</div>
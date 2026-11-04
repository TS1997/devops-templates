<?php
/**
 * Template to override hero render
 *
 * @package BbaseTheme
 */

if ( ! isset( $args['content'] ) || empty( $args['content'] ) ) {
	return;
}

?>

<?php if ( ! empty( $args['content']['pretitle'] ) ) : ?>
	<h2 class="braavos-content__pretitle">
		<?php echo wp_kses_post( $args['content']['pretitle'] ); ?>
	</h2>
<?php endif; ?>
<?php if ( ! empty( $args['content']['title'] ) ) : ?>
	<h3 class="braavos-content__title"><?php echo esc_html( $args['content']['title'] ); ?></h3>
<?php endif; ?>
<div class="braavos-content__lead">
	<?php echo wp_kses_post( apply_filters( 'the_content', $args['content']['content'] ) ); ?>
</div>
	
<?php if ( ! empty( $args['content']['cta'] ) ) : ?>
	<?php
	get_template_part(
		'template-parts/components/component',
		'link',
		array(
			'link'      => esc_url( $args['content']['cta'] ),
			'classname' => 'braavos-content__cta',
		)
	);
	?>
<?php endif; ?>
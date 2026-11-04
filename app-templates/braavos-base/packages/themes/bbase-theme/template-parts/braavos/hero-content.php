<?php
/**
 * Template to override hero render
 *
 * @package BbaseTheme
 */

?>

<div class="braavos-foreground__content">
	<h2 class="braavos-foreground__title"><?php echo esc_html( $args['title'] ); ?></h2>
	<div class="braavos-foreground__lead">
		<?php echo wp_kses_post( apply_filters( 'the_content', $args['content'] ) ); ?>
	</div>
	<?php
	get_template_part(
		'template-parts/components/component',
		'cta',
		array(
			'call_to_action' => $args['call_to_action'],
			'classname'      => 'braavos-foreground',
		)
	);
	?>
</div>
<?php if ( isset( $args['emblem'] ) && is_array( $args['emblem'] ) ) : ?>
	<div class="braavos-foreground__emblem">
		<?php echo wp_get_attachment_image( $args['emblem']['id'], 'large' ); ?>
	</div>
<?php endif; ?>
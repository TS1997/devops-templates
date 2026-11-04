<?php
/**
 * Call to action component
 *
 * @package BbaseTheme
 */

$classname = 'block';
if ( isset( $args['classname'] ) && is_string( $args['classname'] ) ) {
	$classname = $args['classname'];
}

if ( isset( $args['call_to_action'] ) && ! empty( $args['call_to_action'] ) && $args['call_to_action'][0]['link'] ) : ?>
	<div class="<?php printf( '%s__cta', esc_attr( $classname ) ); ?>">
		<?php foreach ( $args['call_to_action'] as $cta ) : ?>

			<?php
			if ( empty( $cta['link'] ) ) {
				continue;}
			?>

			<?php
			$button_classname = array(
				sprintf( '%s__button', $classname ),
				$cta['primary'] ? sprintf( '%s__button--primary', $classname ) : sprintf( '%s__button--link', $classname ),
			);
			?>

			<?php
			get_template_part(
				'template-parts/components/component',
				'link',
				array(
					'link'      => $cta['link'],
					'classname' => implode( ' ', $button_classname ),
				)
			);
			?>

		<?php endforeach; ?>
	</div>
<?php endif; ?>

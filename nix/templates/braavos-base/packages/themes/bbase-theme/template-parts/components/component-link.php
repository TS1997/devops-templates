<?php
/**
 * Link component
 *
 * @package BbaseTheme
 */

?>

<a href="<?php echo esc_url( $args['link']['url'] ); ?>"
	target="<?php echo esc_attr( $args['link']['target'] ); ?>" 
	class="<?php echo esc_attr( $args['classname'] ); ?> ">
	<?php echo esc_html( $args['link']['title'] ); ?>
</a>
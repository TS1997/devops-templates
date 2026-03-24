<?php
/**
 * Template part for displaying posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package bbase-theme
 */

?>

<div class="loop-item">
	<?php if ( has_post_thumbnail() ) : ?>
		<a href="<?php echo esc_url( get_the_permalink() ); ?>" class="loop-item__image-link">
			<?php the_post_thumbnail( 'post-thumbnail', array( 'class' => 'loop-item__image' ) ); ?>
		</a>
	<?php endif; ?>
	<div class="loop-item__meta">
		<?php if ( is_search() ) : ?>	
			<?php if ( 'post' === get_post_type() ) : ?>
				<?php // translators: %s: post date in Y-m-d format. ?>
				<?php printf( esc_html__( 'Published: %s', 'bbase-theme' ), get_the_date( 'Y-m-d' ) ); ?>
			<?php else : ?>
				<?php $item_post_type_object = get_post_type_object( get_post_type() ); ?>
				<?php echo esc_html( $item_post_type_object->labels->singular_name ); ?>
			<?php endif; ?>
		<?php else : ?>
			<?php echo esc_html( get_the_date( 'Y-m-d' ) ); ?>
		<?php endif; ?>
	</div>
	<h2 class="loop-item__title"><?php echo esc_html( get_the_title() ); ?></h2>
	<div class="loop-item__excerpt">
		<?php the_excerpt(); ?>
	</div>
	<a class="loop-item__link" href="<?php echo esc_url( get_the_permalink() ); ?>" class="loop-item__link"><?php echo esc_html__( 'Read more', 'bbase-theme' ); ?></a>
</div>


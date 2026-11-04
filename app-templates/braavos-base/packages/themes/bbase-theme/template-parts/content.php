<?php
/**
 * Template part for displaying posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package bbase-theme
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<header class="entry-header">
		<?php if ( is_singular() ) : ?>
			<?php the_title( '<h1 class="entry-header__title">', '</h1>' ); ?>
		<?php else : ?>
			<?php the_title( '<h2 class="entry-header__title"><a href="' . esc_url( get_permalink() ) . '" rel="bookmark">', '</a></h2>' ); ?>
		<?php endif; ?>

		<?php if ( 'post' === get_post_type() ) : ?>
			<div class="entry-header__meta">
				<?php echo get_the_date( 'Y-m-d' ); ?>
			</div><!-- .entry-meta -->
		<?php endif; ?>
		
		<?php if ( has_post_thumbnail() ) : ?>
			<div class="entry-header__image">
				<?php the_post_thumbnail(); ?>
			</div>
		<?php endif; ?>
		
		<?php if ( get_field( 'lead' ) ) : ?>
			<div class="entry-header__lead">
				<?php echo esc_html( get_field( 'lead' ) ); ?>
			</div>
		<?php endif; ?>
	</header><!-- .entry-header -->

	<div class="entry-content">
		<?php
		the_content(
			sprintf(
				wp_kses(
					/* translators: %s: Name of current post. Only visible to screen readers */
					__( 'Continue reading<span class="screen-reader-text"> "%s"</span>', 'bbase-theme' ),
					array(
						'span' => array(
							'class' => array(),
						),
					)
				),
				wp_kses_post( get_the_title() )
			)
		);
		?>
	</div><!-- .entry-content -->

</article><!-- #post-<?php the_ID(); ?> -->

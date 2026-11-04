<?php
/**
 * The template for displaying archive pages
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package bbase-theme
 */

get_header();
?>
	<main id="primary" class="site-main">
		<?php if ( have_posts() ) : ?>
			<header class="entry-header">
				<?php the_archive_title( '<h1 class="entry-header__title">', '</h1>' ); ?>
				<?php the_archive_description( '<div class="entry-header__description">', '</div>' ); ?>
			</header><!-- .page-header -->
			<div class="loop-container">
				<?php
				/* Start the Loop */
				while ( have_posts() ) :
					the_post();

						/*
						* Include the Post-Type-specific template for the content.
						* If you want to override this in a child theme, then include a file
						* called content-___.php (where ___ is the Post Type name) and that will be used instead.
						*/
						get_template_part( 'template-parts/loop', 'item' );
				endwhile;
				?>
			</div>
			<?php
		else :
			get_template_part( 'template-parts/content', 'none' );
		endif;
		?>
	</main><!-- #main -->
<?php
get_sidebar();
get_footer();

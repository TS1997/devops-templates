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
			<?php if ( get_option( 'page_for_posts', true ) ) : ?>
				<header class="entry-header">
					<h1 class="entry-header__title"><?php echo esc_html( get_the_title( get_option( 'page_for_posts', true ) ) ); ?></h1>
					<?php echo esc_html( get_field( 'lead', get_option( 'page_for_posts' ) ) ); ?>
				</header><!-- .page-header -->
			<?php endif; ?>
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

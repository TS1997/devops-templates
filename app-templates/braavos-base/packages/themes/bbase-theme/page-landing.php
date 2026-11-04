<?php
/**
 * Template Name: Modular Page
 *
 * This template is used for rendering Braavos Modules
 *
 * @package bbase-theme
 */

get_header();
?>

	<main id="primary" class="site-main">

		<?php
		while ( have_posts() ) :
			the_post();

			get_template_part( 'template-parts/content', 'braavos' );

		endwhile; // End of the loop.
		?>

	</main><!-- #main -->

<?php
get_footer();

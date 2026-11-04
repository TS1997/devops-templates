<?php
/**
 * The template for displaying 404 pages (not found)
 *
 * @link https://codex.wordpress.org/Creating_an_Error_404_Page
 *
 * @package bbase-theme
 */

get_header();
?>

	<main id="primary" class="site-main">

		<section class="error-404 not-found">
			<header class="entry-header">
				<h1 class="entry-header__title"><?php esc_html_e( 'Oops! That page can&rsquo;t be found.', 'bbase-theme' ); ?></h1>
			</header><!-- .page-header -->

			<div class="entry-content">
				<p><?php esc_html_e( 'It looks like nothing was found at this location. Maybe navigate to the start page or try a search?', 'bbase-theme' ); ?></p>
				
				<div class="error-404__search">
					<?php get_search_form(); ?>
				</div>
				<?php
				get_template_part(
					'template-parts/components/component',
					'cta',
					array(
						'call_to_action' => array(
							array(
								'link'    => array(
									'url'    => home_url( '/' ),
									'title'  => __( 'Start page', 'bbase-theme' ),
									'target' => '_target',
								),
								'primary' => true,
							),
						),
						'classname'      => 'error-404',
					)
				);
				?>
				</p>
					

			</div><!-- .page-content -->
		</section><!-- .error-404 -->

	</main><!-- #main -->

<?php
get_footer();

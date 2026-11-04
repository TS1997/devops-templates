<?php
/**
 * Template part for displaying no posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package bbase-theme
 */

?>

<header class="entry-header">
	<h1 class="entry-header__title">
		<?php echo esc_html__( 'No search results', 'bbase-theme' ); ?>
	</h1>
</header><!-- .page-header -->

<div class="entry-content">
	<p>
		<?php
		/* translators: %s: search query. */
		printf( esc_html__( 'Unfortunately, we could not find any search results for: %s. Check your spelling or try searching for a different word.', 'bbase-theme' ), '<b>‘' . get_search_query() . '’</b>' );
		?>
	</p>
</div>

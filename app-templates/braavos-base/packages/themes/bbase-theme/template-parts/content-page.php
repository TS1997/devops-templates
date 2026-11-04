<?php
/**
 * Template part for displaying page content in page.php
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package bbase-theme
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<header class="entry-header">
		<?php the_title( '<h1 class="entry-header__title">', '</h1>' ); ?>
		<?php if ( has_post_thumbnail() ) : ?>
			<?php the_post_thumbnail( 'content', array( 'class' => 'entry-header__image' ) ); ?>
		<?php endif; ?>
		<?php if ( get_field( 'lead' ) ) : ?>
			<div class="entry-header__lead"><?php echo esc_html( get_field( 'lead' ) ); ?></div>
		<?php endif; ?>
		<?php
		get_template_part(
			'template-parts/components/component',
			'cta',
			array(
				'call_to_action' => esc_html( get_field( 'call_to_action' ) ),
				'classname'      => 'entry-header',
			)
		);
		?>
	</header><!-- .entry-header -->

	<div class="entry-content">
		<?php the_content(); ?>
	</div><!-- .entry-content -->

</article><!-- #post-<?php the_ID(); ?> -->

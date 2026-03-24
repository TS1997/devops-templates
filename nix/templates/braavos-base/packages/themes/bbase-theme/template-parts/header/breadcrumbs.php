<?php
/**
 * Render breadcrumbs
 *
 * @package BbaseTheme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

use RankMath\Frontend\Breadcrumbs;

if ( ! class_exists( 'RankMath\Frontend\Breadcrumbs' ) ) {
	return;
}

$breadcrumbs  = new Breadcrumbs();
$i            = 0;
$crumbs       = $breadcrumbs->get_crumbs();
$crumbs_count = count( $crumbs );

if ( 0 === $crumbs_count ) {
	return;
}

/**
 * Conditions for breadcrumbs visibility
 */
if ( is_front_page() ) {
	return;
}

?>

<div id="breadcrumbs" class="site-breadcrumbs">
	<nav role="navigation" class="site-breadcrumbs__container" >
		<ol class="site-breadcrumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList" aria-label="breadcrumb navigation">
			<?php
			foreach ( $crumbs as $crumb ) :
				++$i;
				?>
				<?php
				/**
				 * $crumb is an array where position 0 is name, position 1 is URL and key 'hide_in_schema' is a boolean wether to hide in schema.
				 * Weird RankMath markup. Perhaps should we make our own?
				 */
				?>
				<?php if ( 2 < $crumbs_count && 1 === $i ) : ?>
					<li class="site-breadcrumbs__item site-breadcrumbs__reveal">
						<a aria-expanded="false" aria-hidden="false" href="<?php echo esc_url( $crumbs[0][1] ); // Output the url to the first crumb. ?>">
							<span class="open">...</span>
							<span class="close"></span>
						</a>
						<span class="site-breadcrumbs__separator">/</span>
					</li>
					<span class="site-breadcrumbs__hideable" aria-hidden="true">
				<?php endif; ?>
				<li class="site-breadcrumbs__item <?php echo $i === $crumbs_count ? 'site-breadcrumbs__item--last' : ''; ?>" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
					<a itemscope itemtype="https://schema.org/Thing" itemprop="item" href="<?php echo esc_url( $crumb[1] ); ?>"<?php echo $i === $crumbs_count ? ' aria-current="page"' : ''; ?>>
						<span itemprop="name"><?php echo esc_html( $crumb[0] ); ?></span>
					</a>
					<meta itemprop="position" content="<?php echo esc_attr( $i ); ?>" />
					<?php if ( $i < $crumbs_count ) : ?>
						<span class="site-breadcrumbs__separator">/</span>
					<?php endif; ?>
				</li>
				<?php if ( 2 < $crumbs_count && ( $crumbs_count - 2 ) === $i ) : ?>
					</span>
				<?php endif; ?>
			<?php endforeach; ?>
		</ol>
	</nav>
</div>

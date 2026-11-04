<?php
/**
 * Nav Menu Class
 *
 * @package BbaseTheme
 */

namespace Bravomedia\BbaseTheme;

/**
 * Customizes the WordPress Nav Menu output
 *
 * @link       https://www.bravomedia.se
 * @since      1.0.0
 *
 * @package    BbaseTheme
 * @subpackage BbaseTheme/includes
 */
class Nav_Menu extends \Walker_Nav_Menu {

	/**
	 * Set the parent Menu Item
	 *
	 * @since 1.0.0
	 *
	 * @var WP_Post $parent The parent menu item.
	 */
	public $parent;

	/**
	 * Set the parent Menu Item
	 *
	 * @since 1.0.0
	 *
	 * @var WP_Post $ancestor The ancestor menu item.
	 */
	public $ancestor;

	/**
	 * Starts the list before the elements are added.
	 *
	 * @since 3.0.0
	 *
	 * @see Walker::start_lvl()
	 *
	 * @param string   $output Used to append additional content (passed by reference).
	 * @param int      $depth  Depth of menu item. Used for padding.
	 * @param stdClass $args   An object of wp_nav_menu() arguments.
	 */
	public function start_lvl( &$output, $depth = 0, $args = null ) {

		parent::start_lvl( $output, $depth, $args );

		if ( $this->ancestor && 0 < $depth ) {
			$unwanted_classnames       = preg_grep( '/^current/', $this->ancestor->classes );
			$unwanted_classnames       = array_merge( $unwanted_classnames, array( 'sub-menu__title', 'menu-item-has-children' ) );
			$this->ancestor->classes   = array_values( array_diff( $this->ancestor->classes, $unwanted_classnames ) );
			$this->ancestor->classes[] = 'sub-menu__back';

			parent::start_el( $output, $this->ancestor, 0, $args, 0 );
			$this->ancestor = false;
		} else {
			$output        .= sprintf( '<li class="menu-item sub-menu__back"><a href="#">%s</a></li>', __( 'Everything', 'bbase-theme' ) );
			$this->ancestor = false;
		}

		if ( $this->parent ) {

			$unwanted_classnames     = preg_grep( '/^current/', $this->parent->classes );
			$unwanted_classnames     = array_merge( $unwanted_classnames, array( 'sub-menu__back', 'menu-item-has-children' ) );
			$this->parent->classes   = array_values( array_diff( $this->parent->classes, $unwanted_classnames ) );
			$this->parent->classes[] = 'sub-menu__title';

			parent::start_el( $output, $this->parent, 0, $args, 0 );

			$this->ancestor = $this->parent;
			$this->parent   = false;
		}
	}

	/**
	 * Starts the element output.
	 *
	 * @since 3.0.0
	 * @since 4.4.0 The {@see 'nav_menu_item_args'} filter was added.
	 * @since 5.9.0 Renamed `$item` to `$data_object` and `$id` to `$current_object_id`
	 *              to match parent class for PHP 8 named parameter support.
	 *
	 * @see Walker::start_el()
	 *
	 * @param string   $output            Used to append additional content (passed by reference).
	 * @param WP_Post  $data_object       Menu item data object.
	 * @param int      $depth             Depth of menu item. Used for padding.
	 * @param stdClass $args              An object of wp_nav_menu() arguments.
	 * @param int      $current_object_id Optional. ID of the current menu item. Default 0.
	 */
	public function start_el( &$output, $data_object, $depth = 0, $args = null, $current_object_id = 0 ) {
		if ( is_array( $data_object->classes ) && in_array( 'menu-item-has-children', $data_object->classes, true ) ) {
			$this->parent = $data_object;
		}
		parent::start_el( $output, $data_object, $depth, $args, $current_object_id );
	}
}

import Navigation from '@10up/component-navigation';

/**
 * See 10up Component Navigation source here:
 * https://github.com/10up/component-navigation/blob/master/src/navigation.js
 */

export function initNav() {
	initPrimary();
}

/**
 * Initializes the primary navigation menu with specified options and event handlers.
 *
 * This function sets up a new Navigation instance for the primary site navigation,
 * configuring various event handlers for menu actions such as opening, closing,
 * and submenu interactions.
 *
 * Options:
 * - action: Specifies the action to trigger the menu (default is 'click').
 * - breakpoint: Sets the breakpoint for responsive behavior (default is false, which uses (min-width: 48em)).
 * - onCreate: Callback function executed when the navigation is created.
 * - onOpen: Callback function executed when the menu is opened.
 * - onClose: Callback function executed when the menu is closed.
 * - onSubmenuOpen: Callback function executed when a submenu is opened.
 * - onSubmenuClose: Callback function executed when a submenu is closed.
 *
 * Event Handlers:
 * - onOpen: Adds 'menu-open' class to the body and html elements, optionally navigates to the current menu item,
 *   opens links, and sets up an overlay click event to close the menu.
 * - onClose: Removes 'menu-open' class from the body and html elements.
 * - onSubmenuOpen: Adds 'menu-swipe' class to the parent element of the opened submenu and sets up submenu back navigation.
 * - onSubmenuClose: Removes 'menu-swipe' class from the parent element of the closed submenu.
 */
function initPrimary() {
	new Navigation('.site-navigation__primary', {
		action: 'click',
		breakpoint: false, // Defaults to (min-width: 48em)
		onCreate() {
			/* Callback content */
		},
		onOpen() {
			document.body.classList.add('menu-open');
			document.documentElement.classList.add('menu-open');

			// Open menu at current menu item
			// disabled since Tuva disapproves
			const autoNavigate = false;
			if (autoNavigate) {
				openCurrentMenuItem();
			}

			openLink();

			const overlay = document.querySelector('.site-overlay');
			overlay.addEventListener('click', closeMenu);
		},
		onClose() {
			document.body.classList.remove('menu-open');
			document.documentElement.classList.remove('menu-open');
		},
		onSubmenuOpen(submenu) {
			const parent = document
				.getElementById(submenu.id)
				.parentElement.closest('ul');
			parent.classList.add('menu-swipe');
			subMenuBack(submenu);
		},
		onSubmenuClose(submenu) {
			const parent = document
				.getElementById(submenu.id)
				.parentElement.closest('ul');
			parent.classList.remove('menu-swipe');
		},
	});
}

/**
 * Opens the link without closing the submenu
 */
function openLink() {
	const submenuTitle = document.querySelectorAll(
		'.site-navigation__primary .menu-item'
	);
	for (const title of submenuTitle) {
		title.addEventListener('click', (e) => {
			e.stopPropagation();
		});
	}
}

/**
 * Closes the current submenu and navigates back
 * @param {HTMLElement} submenu
 */
function subMenuBack(submenu) {
	const back = submenu.querySelector('.sub-menu__back a');
	back.addEventListener('click', (event) => {
		event.preventDefault();
		event.stopPropagation();

		submenu.setAttribute('aria-hidden', true);
		submenu.previousElementSibling.setAttribute('aria-expanded', false);

		const parent = document
			.getElementById(submenu.id)
			.parentElement.closest('ul');
		parent.classList.remove('menu-swipe');
	});
}

/**
 * Kill link default behavior
 *
 * @param { Node } event
 */
function stopPageLoad(event) {
	event.preventDefault();
	event.stopPropagation();
}

/**
 * Navigate a link in the navigation system
 *
 * @param { Node } link
 */
function navigate(link) {
	link.addEventListener('click', stopPageLoad);
	link.click();
	link.removeEventListener('click', stopPageLoad);
}

/**
 * Closes the Menu
 *
 * @param { Node } event
 */
function closeMenu(event) {
	event.preventDefault();
	event.stopPropagation();
	if (document.body.classList.contains('menu-open')) {
		const menu = document.querySelector('.site-navigation__toggle');
		menu.click();
	}
}

/**
 * Open menu at current page
 *
 */
function openCurrentMenuItem() {
	const currentMenuItem = document.querySelectorAll(
		'.site-navigation__primary .current-menu-parent a[aria-expanded=true]'
	);
	if (0 < currentMenuItem.length) {
		return;
	}
	const currentMenuAncestors = document.querySelectorAll(
		'.site-navigation__primary .current-menu-ancestor'
	);
	const items = currentMenuAncestors.length;
	for (let i = 0; i < items; i++) {
		navigate(currentMenuAncestors[i].querySelector('a'));

		/**
		 * This condition navigates the last step of the navigation if you navigated to
		 * a sub-menu__title page that has its own submenu
		 */
		if (i === items - 1) {
			const currentNav = currentMenuAncestors[i].querySelector(
				'.current-menu-item.menu-item-has-children a'
			);
			if (currentNav !== null) {
				navigate(currentNav);
			}
		}
	}
}

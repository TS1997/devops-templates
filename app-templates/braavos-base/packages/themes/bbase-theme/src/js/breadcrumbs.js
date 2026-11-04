import resolveConfig from 'tailwindcss/resolveConfig';
import tailwindConfig from '../../tailwind.config.js';

const tailwind = resolveConfig(tailwindConfig);

/**
 * Initializes collapsible breadcrumbs functionality.
 *
 * This function sets up the breadcrumbs to be collapsible, allowing the user to reveal or hide
 * parts of the breadcrumb trail. It adds event listeners for window resize and click events
 * on the reveal button to manage the visibility of the breadcrumbs.
 *
 * The function expects the following HTML structure:
 * <div id="breadcrumbs">
 *   <div class="site-breadcrumbs__hideable">...</div>
 *   <div class="site-breadcrumbs__reveal"><a href="#">Reveal</a></div>
 * </div>
 *
 * If any of the required elements are not found, the function will return early.
 *
 * @function
 */
export function collapsableBreadcrumbs() {
	const breadcrumbs = document.getElementById('breadcrumbs');
	if (breadcrumbs === null) {
		return;
	}
	const crumbHideable = breadcrumbs.querySelector(
		'.site-breadcrumbs__hideable'
	);
	const crumbRevealBtn = breadcrumbs.querySelector(
		'.site-breadcrumbs__reveal > a'
	);

	if (
		null === breadcrumbs ||
		null === crumbHideable ||
		null === crumbRevealBtn
	) {
		return;
	}

	setup(breadcrumbs, crumbRevealBtn, crumbHideable);
	window.addEventListener('resize', function () {
		setup(breadcrumbs, crumbRevealBtn, crumbHideable);
	});
	crumbRevealBtn.addEventListener('click', function (event) {
		event.preventDefault();
		toggleBreadcrumbs(breadcrumbs, crumbRevealBtn, crumbHideable);
	});
}

/**
 * Sets up the breadcrumbs functionality based on the media query match.
 *
 * @param {HTMLElement} breadcrumbs    - The breadcrumbs element.
 * @param {HTMLElement} crumbRevealBtn - The button to reveal the breadcrumbs.
 * @param {HTMLElement} crumbHideable  - The element that can be hidden in the breadcrumbs.
 */
function setup(breadcrumbs, crumbRevealBtn, crumbHideable) {
	if (false === matchMedia()) {
		desktop(breadcrumbs, crumbRevealBtn, crumbHideable);
	} else {
		close(breadcrumbs, crumbRevealBtn, crumbHideable);
	}
}

/**
 * Checks if the current window width matches the specified media query.
 *
 * @return {boolean} True if the window width is less than or equal to the medium breakpoint defined in Tailwind CSS, otherwise false.
 */
function matchMedia() {
	const mq = window.matchMedia(
		'(max-width: ' + tailwind.theme.screens.md + ')'
	);
	return mq.matches;
}

/**
 * Adjusts the breadcrumb navigation for desktop view.
 *
 * @param {HTMLElement} breadcrumbs    - The breadcrumb container element.
 * @param {HTMLElement} crumbRevealBtn - The button element to reveal breadcrumbs.
 * @param {HTMLElement} crumbHideable  - The element containing hideable breadcrumbs.
 */
function desktop(breadcrumbs, crumbRevealBtn, crumbHideable) {
	breadcrumbs.classList.remove('site-breadcrumbs--expanded');
	crumbRevealBtn.setAttribute('aria-expanded', 'true');
	crumbHideable.setAttribute('aria-hidden', 'false');
}

/**
 * Toggles the visibility of breadcrumbs based on the current state of the reveal button.
 *
 * @param {HTMLElement} breadcrumbs    - The breadcrumbs container element.
 * @param {HTMLElement} crumbRevealBtn - The button element used to reveal or hide the breadcrumbs.
 * @param {HTMLElement} crumbHideable  - The element within the breadcrumbs that can be hidden or shown.
 */
function toggleBreadcrumbs(breadcrumbs, crumbRevealBtn, crumbHideable) {
	const expanded = crumbRevealBtn.getAttribute('aria-expanded');
	if ('true' === expanded) {
		close(breadcrumbs, crumbRevealBtn, crumbHideable);
	} else if ('false' === expanded) {
		open(breadcrumbs, crumbRevealBtn, crumbHideable);
	}
}

/**
 * Closes the breadcrumbs by removing the expanded class and updating ARIA attributes.
 *
 * @param {HTMLElement} breadcrumbs    - The breadcrumbs container element.
 * @param {HTMLElement} crumbRevealBtn - The button element that reveals the breadcrumbs.
 * @param {HTMLElement} crumbHideable  - The element that can be hidden within the breadcrumbs.
 */
function close(breadcrumbs, crumbRevealBtn, crumbHideable) {
	breadcrumbs.classList.remove('site-breadcrumbs--expanded');
	crumbRevealBtn.setAttribute('aria-expanded', 'false');
	crumbHideable.setAttribute('aria-hidden', 'true');
}

/**
 * Expands the breadcrumbs section by adding the 'site-breadcrumbs--expanded' class,
 * setting the 'aria-expanded' attribute of the reveal button to 'true',
 * and setting the 'aria-hidden' attribute of the hideable element to 'false'.
 *
 * @param {HTMLElement} breadcrumbs    - The breadcrumbs container element.
 * @param {HTMLElement} crumbRevealBtn - The button element that reveals the breadcrumbs.
 * @param {HTMLElement} crumbHideable  - The element that can be hidden or shown within the breadcrumbs.
 */
function open(breadcrumbs, crumbRevealBtn, crumbHideable) {
	breadcrumbs.classList.add('site-breadcrumbs--expanded');
	crumbRevealBtn.setAttribute('aria-expanded', 'true');
	crumbHideable.setAttribute('aria-hidden', 'false');
}

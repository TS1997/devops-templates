import Headroom from 'headroom.js';

/**
 * Initializes the Headroom.js functionality on the site header.
 *
 */
export function followHeader() {
	const header = document.getElementById('site-header');

	const headroom = new Headroom(header, {
		offset: header.offsetHeight,
	});

	headroom.init();
}

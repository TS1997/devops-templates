export function initSearch() {
	initSiteSearch();
}

function initSiteSearch() {
	const searchForm = document.getElementById('site-search');
	const searchToggle = document.querySelectorAll(
		'[aria-controls=site-search]'
	);

	searchForm.setAttribute('aria-hidden', 'true');

	for (const toggle of searchToggle) {
		toggle.setAttribute('aria-expanded', 'false');
		toggleSearch(toggle, searchForm);
	}
}

/**
 * Toggle the menu visibility
 *
 * @param { HTMLElement } toggle
 * @param { HTMLElement } search
 */
function toggleSearch(toggle, search) {
	toggle.addEventListener('click', function (event) {
		event.preventDefault();
		event.stopPropagation();
		const expanded = toggle.getAttribute('aria-expanded');
		if ('false' === expanded) {
			search.setAttribute('aria-hidden', 'false');
			toggleAria('true');
			document.body.classList.add('search-open');
			document.documentElement.classList.add('search-open');
		} else if ('true' === expanded) {
			search.setAttribute('aria-hidden', 'true');
			toggleAria('false');
			document.body.classList.remove('search-open');
			document.documentElement.classList.remove('search-open');
		}
	});
	const overlay = document.querySelector('.site-overlay');
	overlay.addEventListener('click', function (event) {
		event.preventDefault();
		event.stopPropagation();
		search.setAttribute('aria-hidden', 'true');
		toggleAria('false');
		document.body.classList.remove('search-open');
		document.documentElement.classList.remove('search-open');
	});
}

/**
 * Toggle the value of all toggle-elements
 *
 * @param { string } value
 */
function toggleAria(value) {
	const toggles = document.querySelectorAll('[aria-controls=site-search]');
	for (const toggle of toggles) {
		toggle.setAttribute('aria-expanded', value);
	}
}

/**
 *
 * TODO: Add Media Query for Aria labels
 */

/** @typedef {import('jquery')} jQuery */

/**
 * Limit max menu depth in admin panel
 * Expects wp_localize_script to have set an object of menu locations
 * in the shape of { location: maxDepth, location2: maxDepth2 }
 * e.g var menu-depths = {"primary":"1","footer":"0"};
 *
 * @param {jQuery} $ - jQuery instance
 */
(function ($) {
	/* global wpNavMenu, themeMenuDepth, jQuery */

	if (typeof wpNavMenu === 'undefined' || !wpNavMenu.options) {
		return;
	}

	// Get initial maximum menu depth, so that we may restore to it later.
	const initialMaxDepth = wpNavMenu.options.globalMaxDepth;

	function setMaxDepth() {
		// Loop through each of the menu locations
		$.each(themeMenuDepth, function (location, maxDepth) {
			if (
				$('#locations-' + location).prop('checked') &&
				maxDepth < wpNavMenu.options.globalMaxDepth
			) {
				// If this menu location is checked
				// and if the max depth for this location is less than the current globalMaxDepth
				// Then set globalMaxDepth to the max depth for this location
				wpNavMenu.options.globalMaxDepth = maxDepth;
			}
		});
	}

	setMaxDepth();

	// Re-run the function if the menu location checkboxes are changed
	$('.menu-theme-locations input').on('change', function () {
		wpNavMenu.options.globalMaxDepth = initialMaxDepth;
		setMaxDepth();
	});
})(jQuery);

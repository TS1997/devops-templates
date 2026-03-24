const mix = require('laravel-mix');

mix.setPublicPath('./')
	.sourceMaps(false, 'source-map')
	.js('src/bbase-theme.js', 'assets/build')
	.js('src/admin.js', 'assets/build')
	.postCss('src/bbase-theme.css', 'assets/build')
	.postCss('src/editor.css', 'assets/build');

// Laravel Mix is deprecated, does not work with apple ARM chips, and will not receive any new features.
// By disabling notifications, we can at least make it work.
mix.disableNotifications();

mix.options({
	postCss: [
		require('autoprefixer'),
		require('postcss-import'),
		require('tailwindcss/nesting')(require('postcss-nested')),
		require('tailwindcss'),
	],
})
	.browserSync({
		proxy: process.env.WP_HOME,
		https:
			process.env.ENABLE_BROWSERSYNC_SSL === 'true'
				? {
						key: process.env.SSL_CERT_KEY,
						cert: process.env.SSL_CERT,
					}
				: false,
	})
	.webpackConfig({
		stats: {
			children: false,
		},
	});

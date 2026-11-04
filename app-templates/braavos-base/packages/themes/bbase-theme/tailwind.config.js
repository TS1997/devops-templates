/** @type {import('tailwindcss').Config} */

const sitePreset = require('./site-preset.js');

module.exports = {
	presets: [sitePreset],
	content: ['./template-parts/**/*.php', './assets/js/**/*.js'],
	theme: {
		extend: {
			colors: {
				black: '#000',
				foreground: {
					light: '#fff',
					DEFAULT: '#000',
				},
				background: '#fff',
			},
			fontFamily: {
				body: ['"Montserrat"', 'sans-serif'],
				icons: ['"Material Symbols Outlined"'],
			},
			backgroundImage: {
				pattern: "url('../images/pattern.svg')",
			},
			aspectRatio: {
				'4/3': '4 / 3',
			},
		},
		container: {
			center: true,
			padding: {
				DEFAULT: '1.5rem',
				md: '2rem',
			},
		},
	},
	plugins: [],
};

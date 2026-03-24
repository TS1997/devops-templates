const round = (num) =>
	num
		.toFixed(7)
		.replace(/(\.[0-9]+?)0+$/, '$1')
		.replace(/\.0$/, '');
const rem = (px) => `${round(px / 16)}rem`;
const em = (px, base) => `${round(px / base)}em`;

module.exports = {
	theme: {
		colors: {
			black: '#000',
			white: '#fff',
			transparent: 'transparent',
			primary: {
				DEFAULT: '#ff0000',
				50: '#fff0f0',
				100: '#ffdddd',
				200: '#ffc0c0',
				300: '#ff9494',
				400: '#ff5757',
				500: '#ff2323',
				600: '#ff0000',
				700: '#d70000',
				800: '#b10303',
				900: '#920a0a',
				950: '#500000',
			},
			secondary: {
				DEFAULT: '#ff9500',
				50: '#fffbea',
				100: '#fff1c5',
				200: '#ffe485',
				300: '#ffcf46',
				400: '#ffb91b',
				500: '#ff9500',
				600: '#e26e00',
				700: '#bb4a02',
				800: '#983908',
				900: '#7c2f0b',
				950: '#481600',
			},
			tetriary: {
				DEFAULT: '#0698ff',
				50: '#edfbff',
				100: '#d6f3ff',
				200: '#b5edff',
				300: '#83e4ff',
				400: '#48d2ff',
				500: '#1eb5ff',
				600: '#0698ff',
				700: '#0084ff',
				800: '#0864c5',
				900: '#0d569b',
				950: '#0e345d',
			},
			grey: {
				DEFAULT: '#6d6d6d',
				50: '#f6f6f6',
				100: '#e7e7e7',
				200: '#d1d1d1',
				300: '#b0b0b0',
				400: '#888888',
				500: '#6d6d6d',
				600: '#5d5d5d',
				700: '#4f4f4f',
				800: '#454545',
				900: '#3d3d3d',
				950: '#222222',
			},
		},
		fontSize: {
			'4xl': [rem(50), em(60, 50)],
			'3xl': [rem(44), em(54, 44)],
			'2xl': [rem(32), em(38, 32)],
			xl: [rem(26), em(32, 26)],
			lg: [rem(22), em(32, 22)],
			md: [rem(18), em(28, 18)],
			base: [rem(16), em(24, 16)],
			sm: [rem(14), em(20, 14)],
			xs: [rem(12), em(16, 12)],
		},
	},
};

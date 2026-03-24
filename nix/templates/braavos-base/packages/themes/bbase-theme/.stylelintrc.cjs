/** Stylelint-config med WordPress-standard + Tailwind-stöd */
module.exports = {
  // Viktigt: Tailwind-konfigen ska komma SIST i extends
  extends: [
    '@wordpress/stylelint-config',
    'stylelint-config-tailwindcss'
  ],

  // Ignorera genererade mappar
  ignoreFiles: [
    '**/node_modules/**',
    '**/vendor/**',
    '**/dist/**',
    '**/build/**'
  ],

  // Olika parser (customSyntax) per filtyp
  overrides: [
    // Vanliga .css-filer
    {
      files: ['**/*.css'],
      customSyntax: 'postcss'
    },
    // SCSS
    {
      files: ['**/*.scss'],
      customSyntax: 'postcss-scss'
    },
    // Inbäddad CSS i HTML/PHP (t.ex. block-templating)
    {
      files: ['**/*.{html,php,twig,blade.php}'],
      customSyntax: 'postcss-html'
    }
  ],

  // Egen finjustering (lägg till/ta bort efter behov)
  rules: {
    'selector-class-pattern': null,
    'declaration-empty-line-before': 'never',
    'rule-empty-line-before': 'always-multi-line',
    "at-rule-empty-line-before": [
      "always",
      {
        "except": ["after-same-name", "inside-block"],
        "ignoreAtRules": ["apply"]
      }
    ],
    'property-disallowed-list': [
      [
        'margin',
        'padding',
        'color',
        'background',
        'background-color',
        'background-image',
        'font-size',
        'font-weight',
        'font-family',
        'line-height',
        'letter-spacing',
        'text-align',
        'text-transform',
        'text-decoration',
        'border',
        'border-radius',
        'border-width',
        'border-color',
        'box-shadow',
        'width',
        'height',
        'min-width',
        'min-height',
        'max-width',
        'max-height',
        'gap',
        'row-gap',
        'column-gap',
        'top',
        'right',
        'bottom',
        'left',
        'z-index',
        'opacity',
        'overflow',
        'overflow-x',
        'overflow-y',
        'object-fit',
        'object-position',
        'order',
        'flex',
        'flex-basis',
        'flex-direction',
        'flex-wrap',
        'align-items',
        'align-content',
        'justify-content',
        'justify-items',
        'justify-self',
        'align-self',
        'grid-template-columns',
        'grid-template-rows',
        'grid-column',
        'grid-row'
      ],
      {
        message: 'Use Tailwind classes instead of specifying these properties directly.',
        severity: 'warning'
      }
    ]
  }
};

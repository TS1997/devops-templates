/** Stylelint configuration with WordPress standard + Tailwind support */
module.exports = {
  // Important: Tailwind configuration should come LAST in extends
  extends: [
    '@wordpress/stylelint-config',
    'stylelint-config-tailwindcss'
  ],

  // Ignore generated folders
  ignoreFiles: [
    '**/node_modules/**',
    '**/vendor/**',
    '**/dist/**',
    '**/build/**'
  ],

  // Different parsers (customSyntax) per file type
  overrides: [
    // Regular .css files
    {
      files: ['**/*.css'],
      customSyntax: 'postcss'
    },
    // SCSS
    {
      files: ['**/*.scss'],
      customSyntax: 'postcss-scss'
    },
    // Embedded CSS in HTML/PHP (e.g., block templating)
    {
      files: ['**/*.{html,php,twig,blade.php}'],
      customSyntax: 'postcss-html'
    }
  ],

  // Custom adjustments (add/remove as needed)
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

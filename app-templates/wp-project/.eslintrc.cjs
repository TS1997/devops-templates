/**
 * ESLint configuration file for the project.
 *
 * @module .eslintrc.cjs
 * @description
 *   - Extends the recommended WordPress ESLint plugin.
 *   - Sets the environment for browser, Node.js, and ECMAScript 2022.
 *   - Uses ECMAScript 2022 syntax and module source type.
 *   - Ignores linting for node_modules, vendor, dist, and build directories.
 *   - Enforces JSDoc comments on functions.
 *
 * @see {@link https://eslint.org/docs/latest/use/configure/}
 * @see {@link https://github.com/WordPress/gutenberg/tree/trunk/packages/eslint-plugin}
 *
 * @eslint
 *   rules:
 *     require-jsdoc: ["error", { "require": { "FunctionDeclaration": true, "MethodDefinition": true, "ClassDeclaration": false, "ArrowFunctionExpression": true, "FunctionExpression": true } }]
 */
module.exports = {
  root: true,
  extends: [
    'plugin:@wordpress/eslint-plugin/recommended',
    'plugin:jsdoc/recommended'
  ],
  plugins: [ 'jsdoc' ],
  env: { browser: true, node: true, es2022: true },
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module'
  },
  ignorePatterns: [
    '**/node_modules/**',
    '**/vendor/**',
    '**/dist/**',
    '**/build/**'
  ],
  rules: {
    'jsdoc/require-jsdoc': [
      'warn',
      {
        require: {
          FunctionDeclaration: true,
          MethodDefinition: true,
          ClassDeclaration: true,
          ArrowFunctionExpression: true,
          FunctionExpression: true
        }
      }
    ]
  }
};

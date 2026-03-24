module.exports = {
  root: true,
  extends: [ 'plugin:@wordpress/eslint-plugin/recommended' ],
  env: { browser: true, node: true, es2022: true },
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module'
  },
  ignorePatterns: [
    'node_modules/',
    'build/',
    '**/node_modules/**',
    '**/vendor/**',
    '**/dist/**',
    '**/build/**'
  ],
};

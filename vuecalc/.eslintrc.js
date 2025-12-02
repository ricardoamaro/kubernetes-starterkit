module.exports = {
  root: true,
  env: {
    node: true
  },
  extends: [
    'plugin:vue/essential'
  ],
  rules: {
    // Disable problematic rules for this tutorial
    'no-tabs': 'off',
    'no-mixed-spaces-and-tabs': 'off',
    'no-trailing-spaces': 'off',
    'semi': 'off',
    'indent': 'off',
    'keyword-spacing': 'off',
    'space-before-blocks': 'off',
    'space-before-function-paren': 'off',
    'brace-style': 'off',
    'quote-props': 'off',
    'eqeqeq': 'off',
    'vue/multi-word-component-names': 'off',
    'vue/require-v-for-key': 'off',
    'no-unused-vars': 'warn',
    'n/no-callback-literal': 'off'
  },
  parserOptions: {
    parser: '@babel/eslint-parser',
    requireConfigFile: false
  }
}

import prettier from 'eslint-config-prettier';
import tseslint from 'typescript-eslint';

export default [
  { ignores: ['node_modules', 'dist', 'coverage', 'jest.config.ts'] },

  // Recommended TypeScript rules (ref: https://typescript-eslint.io/getting-started/)
  ...tseslint.configs.recommended,

  // Optional stricter overrides and rules
  {
    files: ['**/*.ts', '**/*.tsx'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/explicit-function-return-type': 'error',
    },
  },

  // Switching off ESLint rules that conflict with Prettier formatting rules (ref: https://github.com/prettier/eslint-config-prettier)
  prettier,
];

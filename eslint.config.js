import prettier from 'eslint-config-prettier';
import sonarjs from 'eslint-plugin-sonarjs';
import tseslint from 'typescript-eslint';

export default [
  {
    ignores: [
      'node_modules',
      'dist',
      'coverage',
      'jest.config.ts',
      '*.config.cjs',
      'util-scripts/**',
      '.vscode',
      '.env.local',
    ],
  },

  // Recommended TypeScript rules (ref: https://typescript-eslint.io/getting-started/)
  ...tseslint.configs.recommended,

  // Optional stricter overrides and rules
  {
    files: ['**/*.ts', '**/*.tsx'],
    plugins: {
      sonarjs,
    },
    rules: {
      'no-duplicate-imports': 'error',

      // Typescript rules
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/explicit-function-return-type': 'error',

      // Function size rules
      'max-depth': ['warn', 4],
      'max-params': ['warn', 4],
      'max-statements': ['warn', 30],
      'max-lines-per-function': [
        'warn',
        { max: 80, skipBlankLines: true, skipComments: true },
      ],

      // Complexity rules
      complexity: ['error', { max: 10 }],
      'sonarjs/cognitive-complexity': ['warn', 20],
    },
  },

  // Turns off all rules that are unnecessary or might conflict with Prettier (ref: https://github.com/prettier/eslint-config-prettier)
  prettier,
];

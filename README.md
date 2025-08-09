# Code katas repo

A repo to write solutions for the code katas from Code Wars

## Typescript config to generate Javascript files

Currently the project is setup to not emit any Javascript files by design. This can be changed in the future by using the following configuration:

```
// {

// Configuration rules to allow the compiler to emit Javascript files

// "compilerOptions": {

// ...other current config

// "moduleResolution": "Bundler", <---change

// // "allowImportingTsExtensions": true, <---remove
// "noEmit": false, <---change

// Source maps and declarations (not needed with noEmit: true)
// "sourceMap": true,
// "declaration": true,
// "declarationMap": true

// //Build
// "outDir": "./dist", <---add

// ...other current config
// }

// }
```

Typescript list of recommended compiler options: [text](https://www.typescriptlang.org/docs/handbook/modules/guides/choosing-compiler-options.html#im-using-tsx) and base config options: [text](https://github.com/tsconfig/bases/?tab=readme-ov-file)

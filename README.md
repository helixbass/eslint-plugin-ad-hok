# eslint-plugin-ad-hok
[Ad-hok](https://www.github.com/helixbass/ad-hok) specific linting rules for ESLint

## Installation
Install [ESLint](https://www.github.com/eslint/eslint)
```
npm install --save-dev eslint
```

Install the plugin
```
npm install --save-dev eslint-plugin-ad-hok
```

## Configuration

Use the [`recommended` preset](#recommended) to get reasonable defaults:
```
"extends": [
  "ad-hok/recommended"
]
```
You may also optionally specify settings that will be shared across all the plugin rules.
```
"settings": {
  "ad-hok/possibly-magic-helper-regex": "add.*|suppress.*", // defaults to "add.*"
  "ad-hok/nonmagic-helper-whitelist": [
    "addTranslationHelpers",
    "addEffectOnMount"
  ],
  "ad-hok/should-fix-flow-flowmax": true, // if you're using eslint-plugin-known-imports
}
```

If you don't use the preset, include the rules that you wish to use:
```
"plugins": ["ad-hok"],
"rules": {
  "ad-hok/no-unnecessary-flowmax": "error",
  "ad-hok/needs-flowmax": "error",
  "ad-hok/prefer-flowmax": ["error", "whenUsingUnknownHelpers"],
  "ad-hok/no-flowmax-in-forwardref": "error"
},
"settings": { // these are all optional
  "ad-hok/possibly-magic-helper-regex": ...,
  "ad-hok/nonmagic-helper-whitelist": ...,
  "ad-hok/should-fix-flow-flowmax": ...
}
```

## Rules

* [`ad-hok/needs-flowmax`](./docs/rules/needs-flowmax.md) - ensure that `flowMax()` is used instead of `flow()` when you are *definitely* using "magic" `ad-hok` helpers
* [`ad-hok/prefer-flowmax`](./docs/rules/prefer-flowmax.md) - ensure that `flowMax()` is used instead of `flow()` when you *may* be using "magic" `ad-hok` helpers (or everywhere)
* [`ad-hok/no-unnecessary-flowmax`](./docs/rules/no-unnecessary-flowmax.md) - ensure that `flow()` is used instead of `flowMax()` when you are *definitely not* using "magic" `ad-hok` helpers
* [`ad-hok/no-flowmax-in-forwardref`](./docs/rules/no-flowmax-in-forwardref.md) - flag uses of `flowMax()` inside [`React.forwardRef()`](https://reactjs.org/docs/forwarding-refs.html)

## Configuration presets

### Recommended

This plugin exports a `recommended` configuration that provides reasonable defaults for enforcing `ad-hok` best practices

To enable this configuration use the `extends` property in your `.eslintrc` config file:
```
{
  "extends": ["plugin:ad-hok/recommended"]
}
```
See [ESLint documentation](http://eslint.org/docs/user-guide/configuring#extending-configuration-files) for more information about extending configuration files

The rules enabled in this configuration are:

* [`ad-hok/needs-flowmax`](./docs/rules/needs-flowmax.md)
* [`ad-hok/prefer-flowmax`](./docs/rules/prefer-flowmax.md) (specifically, `"ad-hok/prefer-flowmax": ["error", "whenUsingUnknownHelpers"]`)
* [`ad-hok/no-flowmax-in-forwardref`](./docs/rules/no-flowmax-in-forwardref.md)

## License

MIT

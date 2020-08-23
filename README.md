# eslint-plugin-ad-hok
[Ad-hok](https://www.github.com/helixbass/ad-hok) specific linting rules for ESLint


## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Rules](#rules)
- [Configuration presets](#configuration-presets)
- [Help / Contributions / Feedback](#help--contributions--feedback)
- [License](#license)



## Installation
Install [ESLint](https://www.github.com/eslint/eslint)
```
npm install --save-dev eslint

# or, if you're using yarn:

yarn add --dev eslint
```

Install the plugin
```
npm install --save-dev eslint-plugin-ad-hok

# or, if you're using yarn:

yan add --dev eslint-plugin-ad-hok
```

## Configuration

#### Using preset

Use the [`recommended` preset](#recommended) to get reasonable defaults:
```
"plugins": ["ad-hok"],
"extends": [
  "plugin:ad-hok/recommended"
]
```

Or, if you're using Typescript, use the [`recommended-typescript` preset](#recommended-typescript) to get reasonable defaults
for Typescript + React projects:
```
"plugins": ["ad-hok"],
"extends": [
  "plugin:ad-hok/recommended-typescript"
]
```

You may also optionally specify settings that will be shared across all the plugin rules.
```
"settings": {
  "ad-hok/should-rewrite-importable-names": true, // if you're using eslint-plugin-known-imports
}
```

#### Manually

If you don't use the preset, include the rules that you wish to use:
```
"plugins": ["ad-hok"],
"rules": {
  "ad-hok/no-flowmax-in-forwardref": "error",
  "ad-hok/dependencies": "error"
}
```



## Rules


* [`ad-hok/no-flowmax-in-forwardref`](./docs/rules/no-flowmax-in-forwardref.md) - flag uses of `flowMax()` inside [`React.forwardRef()`](https://reactjs.org/docs/forwarding-refs.html)
* [`ad-hok/dependencies`](./docs/rules/dependencies.md) - check that dependencies arguments match used props
* [`ad-hok/require-adddisplayname`](./docs/rules/require-adddisplayname.md) - check that components set a display name with `addDisplayName()`

Typescript-specific rules:
* [`ad-hok/cleanupprops-last`](./docs/rules/cleanupprops-last.md) - check that `cleanupProps()` is only used at the end of ad-hok helper chains
* [`ad-hok/annotate-handler-param-types`](./docs/rules/annotate-handler-param-types.md) - check that handler params have explicit type annotations
* [`ad-hok/getcontexthelpers-argument`](./docs/rules/getcontexthelpers-argument.md) - autofix [`getContextHelpers()`](https://github.com/helixbass/ad-hok-utils#getcontexthelpers)'s argument


## Configuration presets

### Recommended

This plugin exports a `recommended` configuration that provides reasonable defaults for enforcing `ad-hok` best practices

To enable this configuration use the `extends` property in your `.eslintrc` config file:
```
{
  "plugins": ["ad-hok"],
  "extends": ["plugin:ad-hok/recommended"]
}
```
See [ESLint documentation](http://eslint.org/docs/user-guide/configuring#extending-configuration-files) for more information about extending configuration files

The rules enabled in this configuration are:

* [`ad-hok/no-flowmax-in-forwardref`](./docs/rules/no-flowmax-in-forwardref.md)
* [`ad-hok/dependencies`](./docs/rules/dependencies.md) (specifically, `"ad-hok/dependencies": ["error", {"effects": false}]`)


### Recommended-Typescript

This plugin exports a `recommended-typescript` configuration that provides reasonable defaults for enforcing `ad-hok` best practices when
you're using Typescript

To enable this configuration use the `extends` property in your `.eslintrc` config file:
```
{
  "plugins": ["ad-hok"],
  "extends": ["plugin:ad-hok/recommended-typescript"]
}
```

The rules enabled in this configuration (in addition to the rules listed for the [`recommended`](#recommnded) preset above) are:

* [`ad-hok/annotate-handler-param-types`](./docs/rules/annotate-handler-param-types.md)
* [`ad-hok/cleanupprops-last`](./docs/rules/cleanupprops-last.md)
* [`ad-hok/getcontexthelpers-argument`](./docs/rules/getcontexthelpers-argument.md)



## Help / Contributions / Feedback

Please file an issue or submit a PR with any questions/suggestions



## License

MIT




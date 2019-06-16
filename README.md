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

In your ESLint config, include the rules that you wish to use:
```
plugins: ["ad-hok"],
rules: {
  "ad-hok/no-unnecessary-flowmax": "error",
  "ad-hok/needs-flowmax": "error",
  "ad-hok/prefer-flowmax": ["error", "whenUsingUnknownHelpers"]
}
```

## Rules

* [`needs-flowmax`](./docs/rules/needs-flowmax.md) - ensure that `flowMax()` is used instead of `flow()` when you are *definitely* using "magic" `ad-hok` helpers
* [`prefer-flowmax`](./docs/rules/prefer-flowmax.md) - ensure that `flowMax()` is used instead of `flow()` when you *may* be using "magic" `ad-hok` helpers (or everywhere)
* [`no-unnecessary-flowmax`](./docs/rules/no-unnecessary-flowmax.md) - ensure that `flow()` is used instead of `flowMax()` when you are *definitely not* using "magic" `ad-hok` helpers

## License

MIT

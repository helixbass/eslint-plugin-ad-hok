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

In your ESLint config, include:
```
plugins: ['ad-hok'],
rules: {
  'ad-hok/no-unnecessary-flowmax': 'error',
  'ad-hok/needs-flowmax': 'error'
}
```

## License

MIT

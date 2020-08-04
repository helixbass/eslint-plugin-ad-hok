# ad-hok/require-adddisplayname

This rule enforces that `flowMax()` components specify a display name using [`addDisplayName()`](https://github.com/helixbass/ad-hok#adddisplayname)

### Motivation

Adding a display name can result in nicer component names when debugging


## Relevant settings

This rule uses the following optional `settings`:

* Adding `"ad-hok/should-fix-importable-names": true` to your `settings` enables automatically generating an `addDisplayName()` for your component
when running ESLint in `--fix` mode. This option is intended for use with
[`eslint-plugin-known-imports`](https://github.com/helixbass/eslint-plugin-known-imports), which will then generate the `import` for
`addDisplayName` as necessary


#### :-1: Examples of incorrect code for this rule:
```js
/*eslint ad-hok/require-adddisplayname: "error"*/

const MyComponent = flowMax(
  addProps({foo: 3}),
  ({foo}) => <div>{foo}</div>
)
```

#### :+1: Examples of correct code for this rule:
```js
/*eslint ad-hok/require-adddisplayname: "error"*/

const MyComponent = flowMax(
  addDisplayName('MyComponent'),
  addProps({foo: 3}),
  ({foo}) => <div>{foo}</div>
)

// won't flag if addDisplayName() is present anywhere in the chain

const MyComponent = flowMax(
  addProps({foo: 3}),
  addDisplayName('MyComponent'),
  ({foo}) => <div>{foo}</div>
)
```

# ad-hok/needs-flowmax

This rules enforces that `flowMax()` is used instead of `flow()` anywhere that *definitely* uses `ad-hok` "magic" helpers

#### :-1: Examples of **incorrect** code for this rule:
```js
/*eslint ad-hok/needs-flowmax: "error"*/

flow(
  branch(({x}) => x > 2, returns(() => null)),
  ({x}) => <div>{x}</div>
)

flow(
  addPropTypes({x: PropTypes.number}),
  ({x}) => <div>{x}</div>
)

flow(
  addWrapper(({render}) => <Wrapper render={render} />),
  ({x}) => <div>{x}</div>
)

flow(
  addWrapperHOC(withNavigation),
  ({navigation}) => ...
)
```

#### :+1: Examples of **correct** code for this rule:
```js
/*eslint ad-hok/needs-flowmax: "error"*/

flow(
  items => items.concat(newItem),
  FP.filter(item => item.available)
)

flow(
  addSomething(),
  addProps({foo: 3}),
  addState('bar', 'setBar'),
)

flowMax(
  addPropTypes({x: PropTypes.number}),
  ({x}) => <div>{x}</div>
)
```

## Options

This rule has an object option
* `"shouldFix": true` enables "fixing" `flow()` -> `flowMax()` when running ESLint in `--fix` mode. This option is intended
for use with [`eslint-plugin-known-imports`](https://github.com/helixbass/eslint-plugin-known-imports), which will then
generate the `import` for `flowMax` and/or remove the `import` for `flow` as necessary

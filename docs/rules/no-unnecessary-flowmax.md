# ad-hok/no-unnecessary-flowmax

This rule enforces that `flow()` is used instead of `flowMax()` anywhere that *definitely does not* use `ad-hok` "magic" helpers

#### :-1: Examples of incorrect code for this rule:
```js
/*eslint ad-hok/no-unnecessary-flowmax: "error"*/

flowMax(
  addProps({foo: 3}),
  ({foo}) => <div>{foo}</div>
)

flowMax(
  addState('foo', 'setFoo'),
  ({foo}) => <div>{foo}</div>
)
```

#### :+1: Examples of correct code for this rule:
```js
/*eslint ad-hok/no-unnecessary-flowmax: "error"*/

flowMax(
  addSomething(),
  ({something}) => <div>{something}</div>
)

flowMax(
  addPropTypes({foo: PropTypes.number}),
  ({foo}) => <div>{foo}</div>
)
```

### Relevant settings

* Adding `"ad-hok/should-fix-importable-names": true` to your `settings` enables "fixing" `flowMax()` -> `flow()` when running ESLint in `--fix` mode. This option is intended
for use with [`eslint-plugin-known-imports`](https://github.com/helixbass/eslint-plugin-known-imports), which will then
generate the `import` for `flow` and/or remove the `import` for `flowMax` as necessary

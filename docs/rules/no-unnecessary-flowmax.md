# ad-hok/no-unnecessary-flowmax

This rule enforces that `flow()` is used instead of `flowMax()` anywhere that *definitely does not* use `ad-hok` "magic" helpers

#### Examples of incorrect code for this rule:
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

#### Examples of correct code for this rule:
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

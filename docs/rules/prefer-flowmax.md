# ad-hok/prefer-flowmax

This rule enforces that `flowMax()` is used instead of `flow()` either (a) *everywhere* or (b) anywhere that *may* use `ad-hok` "magic" helpers

## Options

This rule can take a string option:

* If it is the default `"always"`, then *all* uses of `flow()` will be flagged
* If it is `"whenUsingUnknownHelpers"`, then uses of `flow()` that *may* use `ad-hok` "magic" helpers will be flagged

When `"always"`, you should disable the `ad-hok/no-unnecessary-flowmax` rule as they will disagree

This rule can take a second option as an object literal:

* When `"whenUsingUnknownHelpers"`, the `helperRegex` option specifies the naming convention for "secondary helpers" that may
use `ad-hok` "magic" helpers. The default is `"helperRegex": "add.*"`
* When `"whenUsingUnknownHelpers"`, the `whitelist` option accepts an array of helper names that should be treated as
definitely non-"magic". The `whitelist` option overrides `helperRegex`
* `"shouldFix": true` enables "fixing" `flow()` -> `flowMax()` when running ESLint in `--fix` mode. This option is intended
for use with [`eslint-plugin-known-imports`](https://github.com/helixbass/eslint-plugin-known-imports), which will then
generate the `import` for `flowMax` and/or remove the `import` for `flow` as necessary

## always

#### :-1: Examples of incorrect code for the default `"always"` option:
```js
/*eslint ad-hok/prefer-flowmax: "error"*/

flow()

flow(
  addProps({foo: 3}),
  ({foo}) => <div>{foo}</div>
)

flow(
  x => x + 2,
  y => y * 3
)
```

#### :+1: Examples of correct code for the default `"always"` option:
```js
/*eslint ad-hok/prefer-flowmax: "error"*/

flowMax(
  addProps({foo: 3}),
  ({foo}) => <div>{foo}</div>
)

flowMax(
  x => x + 2,
  y => y * 3
)
```

## whenUsingUnknownHelpers

#### :-1: Examples of incorrect code for the `"whenUsingUnknownHelpers"` option:
```js
/*eslint ad-hok/prefer-flowmax: ["error", "whenUsingUnknownHelpers"]*/

flow(
  addSomething,
  ({something}) => <div>{foo}</div>
)

flow(
  addSomething(),
  ({something}) => <div>{foo}</div>
)
```

#### :+1: Examples of correct code for the `"whenUsingUnknownHelpers"` option:
```js
/*eslint ad-hok/prefer-flowmax: ["error", "whenUsingUnknownHelpers"]*/

flowMax(
  addSomething,
  ({something}) => <div>{foo}</div>
)

flowMax(
  addSomething(),
  ({something}) => <div>{foo}</div>
)

flow(
  addProps({foo: 3}),
  ({foo}) => <div>{foo}</div>
)

flow(
  notAConventionallyNamedHelper(),
  ({foo}) => <div>{foo}</div>
)
```

## helperRegex

#### :-1: Examples of incorrect code for the `"helperRegex"` option:
```js
/*eslint ad-hok/prefer-flowmax: ["error", "whenUsingUnknownHelpers", { "helperRegex": "getMagic.*" }]*/

flow(
  getMagicFoo(),
  ({foo}) => <div>{foo}</div>
)
```

#### :+1: Examples of correct code for the `"helperRegex"` option:
```js
/*eslint ad-hok/prefer-flowmax: ["error", "whenUsingUnknownHelpers", { "helperRegex": "getMagic.*" }]*/

flowMax(
  getMagicFoo(),
  ({foo}) => <div>{foo}</div>
)

flow(
  addIsNowNotAFlaggedPrefix,
  ({foo}) => <div>{foo}</div>
)
```

## whitelist

#### :-1: Examples of incorrect code for the `"whitelist"` option:
```js
/*eslint ad-hok/prefer-flowmax: ["error", "whenUsingUnknownHelpers", { "whitelist": ["addSpice", "addSalt"] }]*/

flow(
  addSomethingNotWhitelisted(),
  ({foo}) => <div>{foo}</div>
)
```

#### :+1: Examples of correct code for the `"whitelist"` option:
```js
/*eslint ad-hok/prefer-flowmax: ["error", "whenUsingUnknownHelpers", { "whitelist": ["addSpice", "addSalt"] }]*/

flowMax(
  addSomethingNotWhitelisted(),
  ({foo}) => <div>{foo}</div>
)

flow(
  addSpice(),
  ({spice}) => <div>{spice}</div>
)

flow(
  addSalt,
  notAConventionallyNamedHelper(),
  ({salt}) => <div>{salt}</div>
)
```

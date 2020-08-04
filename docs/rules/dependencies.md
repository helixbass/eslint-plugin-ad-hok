# ad-hok/dependencies

This rule enforces that dependencies arguments to [`addProps()`](https://github.com/helixbass/ad-hok#addprops),
[`addHandlers()`](https://github.com/helixbass/ad-hok#addhandlers),
[`addEffect()`](https://github.com/helixbass/ad-hok#addeffect) and [`addLayoutEffect()`](https://github.com/helixbass/ad-hok#addlayouteffect)
match the actual used props

This rule is conceptually similar to the React hooks ESLint plugin's `exhaustive-deps` rule

Ths rule only flags instances where you're destructuring the props parameter directly (so can't trace eg `props.foo` references)

Since [ad-hok dependencies arguments](https://github.com/helixbass/ad-hok#dependencies-arguments) accept Lodash `get()`-style paths, this rule
checks that path-style dependencies correspond to the destructured prop sub-properties


### Options

This rule has an optional object option:
```
"ad-hok/dependencies": ["error", {"effects": false}]
```
The `effects` option defaults to `true` and indicates whether to check dependencies for `addEffect()`/`addLayoutEffect()`.
This option exists because it's much more common for dependencies not to be comprehensive for effects, where you're just
specifying a condition for triggering the effect - for other helpers where you're recomputing a memoized value, failure
to list dependencies comprehensively will almost always mean the possibility of stale computed values

#### :-1: Examples of incorrect code for the default `"effects": true` option:
```js
/*eslint ad-hok/dependencies: "error"*/

// missing `"a"` dependency:

const MyComponent = flowMax(
  addProps(({a}) => ({
    b: a + 1,
  }), []),
  ({b}) => <div>{b}</div>
)

// unused `"b"` dependency:

const MyComponent = flowMax(
  addHandlers({
    onClick: ({a}) => () => {
      doSomething(a)
    },
  }), ['a', 'b']),
  ({onClick}) => <button onClick={onClick}>click</button>
)

// missing `"a.b"` dependency, unused `"a.c"` dependency:

const MyComponent = flowMax(
  addEffect(({a: {b}}) => () => {
    console.log(b)
  }, ['a.c']),
  () => <div>hello</div>
)

```

#### :+1: Examples of correct code for the default `"effects": true` option:
```js
/*eslint ad-hok/dependencies: "error"*/

const MyComponent = flowMax(
  addProps(({a}) => ({
    b: a + 1,
  }), ['a']),
  addHandlers({
    onClick: ({a}) => () => {
      doSomething()
    },
  }), ['a']),
  addEffect(({a: {b}}) => () => {
    console.log(b)
  }, ['a.b']),
  // "covering" path dependencies are fine too:
  addEffect(({a: {b: {c}, d: {e}}}) => () => {
    console.log(c, e)
  }, ['a.b', 'd']),
  ({b}) => <div>{b}</div>
)
```


#### :+1: Examples of correct code for the `"effects": false` option:
```js
/*eslint ad-hok/dependencies: "error"*/


// don't check effects:

const MyComponent = flowMax(
  addState('value', 'setValue', 0),
  addEffect(({flag, setValue}) => () => {
    if (flag) {
      setValue(1)
    }
  }, ['flag']),
  () => <div>hello</div>
)
```

# ad-hok/no-flowmax-in-forwardref

This rule enforces that `flowMax()` is not used inside of calls to [`React.forwardRef()`](https://reactjs.org/docs/forwarding-refs.html)

### Motivation

Since `ad-hok` "magic" helpers create new React components under the hood, using a "magic" helper (inside of `flowMax()`) within
`React.forwardRef()` (which gets called on every render) would result in a new React component getting created on every render,
which is problematic (the component will always get remounted since React thinks it's a different component than on the previous
render)

So it's a good idea not to use `flowMax()` inside `React.forwardRef()`

### Solution

Instead, prefer "hoisting" the `flowMax()` into a separate component defined outside of the `React.forwardRef()` call

For example, instead of this:
```js
const Button = React.forwardRef((props, ref) =>
  flowMax(
    addPropTypes({onClick: PropTypes.func.isRequired}),
    ({onClick, forwardedRef}) =>
      <button className="button" onClick={onClick} ref={forwardedRef} />
  )({...props, forwardedRef: ref})
)
```
prefer this:
```js
const ButtonWithForwardedRef = flowMax(
  addPropTypes({onClick: PropTypes.func.isRequired}),
  ({onClick, forwardedRef}) =>
    <button className="button" onClick={onClick} ref={forwardedRef} />
)

const Button = React.forwardRef((props, ref) =>
  <ButtonWithForwardedRef {...props} forwardedRef={ref} />
)
```

#### :-1: Examples of incorrect code for this rule:
```js
/*eslint ad-hok/no-flowmax-in-forwardref: "error"*/

const Foo = React.forwardRef((props, forwardedRef) => {
  const InnerFoo = flowMax(
    ({bar, forwardedRef}) =>
      <div ref={forwardedRef}>{bar}</div>
  )
  return <InnerFoo {...props} forwardedRef={forwardedRef} />
})

export default forwardRef((props, ref) =>
  callWith({...props, ref})(
    flowMax(
      addProps({foo: 'bar'}),
      ({foo, ref}) =>
        <div ref={ref}>{foo}</div>
    )
  )
)
```

#### :+1: Examples of correct code for this rule:
```js
/*eslint ad-hok/no-flowmax-in-forwardref: "error"*/

const HoistedComponent = flowMax(
  addWrapper(({render, forwardedRef}) => <div ref={forwardedRef}>{render()}</div>),
  ({foo}) => <span>{foo}</span>
)
const Component = React.forwardRef((props, ref) =>
  <HoistedComponent {...props} forwardedRef={ref} />
)

const Foo = forwardRef((props, ref) =>
  flow(
    addProps(({foo}) => ({bar: foo + 1})),
    ({bar, ref}) => <div ref={ref}>{bar}</div>
  )({...props, ref})
)
```

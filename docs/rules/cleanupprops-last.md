# ad-hok/cleanupprops-last

This rule checks that [`cleanupProps()`](https://github.com/helixbass/ad-hok-utils#cleanupprops) from
[`ad-hok-utils`](https://github.com/helixbass/ad-hok-utils) only appears as the last step of an ad-hok helper chain

This rule only checks Typescript files (because it's just a type-safety consideration) so does not need to be enabled for
non-Typescript projects

### Motivation

Since `cleanupProps()` pretends (from a typing perspective) that props are still present that have actually been removed,
it's dangerous to use it anywhere except as a final "cleanup" step in an ad-hok helper

#### :-1: Examples of incorrect code for this rule:
```typescript
/*eslint ad-hok/cleanupprops-last: "error"*/

type AddBar = SimplePropsAdder<{bar: number}>

const addBar: AddBar = flowMax(
  addProps({
    foo: 2,
  }),
  addProps(({foo}) => ({
    bar: foo + 1,
  })),
  cleanupProps(['foo']),
  addEffect(({bar}) => () => {
    console.log(bar)
  })
)



const MyComponent: FC = flowMax(
  addProps({
    foo: 2,
  }),
  addProps(({foo}) => ({
    bar: foo + 1,
  })),
  cleanupProps(['foo']),
  ({bar}) => <div>{bar}</div>
)
```

#### :+1: Examples of correct code for this rule:
```typescript
/*eslint ad-hok/cleanupprops-last: "error"*/

type AddBar = SimplePropsAdder<{bar: number}>

const addBar: AddBar = flowMax(
  addProps({
    foo: 2,
  }),
  addProps(({foo}) => ({
    bar: foo + 1,
  })),
  addEffect(({bar}) => () => {
    console.log(bar)
  }),
  cleanupProps(['foo'])
)



const MyComponent: FC = flowMax(
  addProps({
    foo: 2,
  }),
  addProps(({foo}) => ({
    bar: foo + 1,
  })),
  removeProps(['foo']),
  ({bar}) => <div>{bar}</div>
)
```






# ad-hok/annotate-handler-param-types

This rule checks that all "inner" handler function parameters have explicit type annotations for
[`addHandlers()`](https://github.com/helixbass/ad-hok#addhandlers),
[`addStateHandlers()`](https://github.com/helixbass/ad-hok#addstatehandlers), and
[`addExtendedHandlers()`](https://github.com/helixbass/ad-hok-utils#addextendedhandlers)
(from [`ad-hok-utils`](https://github.com/helixbass/ad-hok-utils))

This rule only checks Typescript files (because it's only related to typing) so does not need to be enabled for
non-Typescript projects

### Motivation

If you don't explicitly type-annotate "inner" handler function parameters, they'll be silently implicitly `any`-typed

#### :-1: Examples of incorrect code for this rule:
```typescript
/*eslint ad-hok/annotate-handler-param-types: "error"*/

const MyComponent: FC = flowMax(
  addHandlers({
    onClick: () => (event) => {
      doSomething(event)
    },
  }),
  ({onClick}) => <button onClick={onClick}>click</button>
)


const MyComponent: FC = flowMax(
  addStateHandlers(
    {
      a: 1,
    },
    {
      incrementA: ({a}) => (by) => ({
        a: a + by,
      }),
    }
  ),
  ({a, incrementA}) =>
    <div>
      <p>{a}</p>
      <button onClick={() => incrementA(1)}>click</button>
    </div>
)
```


#### :+1: Examples of correct code for this rule:
```typescript
/*eslint ad-hok/annotate-handler-param-types: "error"*/

const MyComponent: FC = flowMax(
  addHandlers({
    onClick: () => (event: React.MouseEvent<HTMLButtonElement>) => {
      doSomething(event)
    },
  }),
  ({onClick}) => <button onClick={onClick}>click</button>
)


const MyComponent: FC = flowMax(
  addStateHandlers(
    {
      a: 1,
    },
    {
      incrementA: ({a}) => (by: number) => ({
        a: a + by,
      }),
    }
  ),
  ({a, incrementA}) =>
    <div>
      <p>{a}</p>
      <button onClick={() => incrementA(1)}>click</button>
    </div>
)
```


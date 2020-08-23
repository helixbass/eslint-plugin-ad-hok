# ad-hok/getcontexthelpers-argument

This rule flags when
[`getContextHelpers()`](https://github.com/helixbass/ad-hok-utils#getcontexthelpersgetcontexthelpersfrominitialvalues)'s
`toObjectKeys()`argument is out-of-sync with the declared context type

It is primarily intended for autofixing since Typescript will also flag mismatches between the context type vs argument

### Relevant settings

* Adding `"ad-hok/should-fix-importable-names": true` to your `settings` enables "fixing" a completely missing `getContextHelpers()`
argument (`toObjectKeys()`) when running ESLint in `--fix` mode. This option is intended
for use with [`eslint-plugin-known-imports`](https://github.com/helixbass/eslint-plugin-known-imports), which will then
generate the `import` for `toObjectKeys` as necessary


#### :-1: Examples of **incorrect** code for this rule:
```js
/*eslint ad-hok/getcontexthelpers-argument: "error"*/

const [addMyContextProvider, addMyContext] = getContextHelpers<{
  a: string
  b: number
}>(toObjectKeys(['a']))



const [addMyContextProvider, addMyContext] = getContextHelpers<{
  a: string
  b: number
}>(toObjectKeys(['a', 'b', 'c']))
```


#### :-1: Examples of **incorrect** code for this rule with the `"ad-hok/should-fix-importable-names": true` setting:
```js
/*eslint ad-hok/getcontexthelpers-argument: "error"*/

const [addMyContextProvider, addMyContext] = getContextHelpers<{
  a: string
  b: number
}>()
```

#### :+1: Examples of **correct** code for this rule:
```js
/*eslint ad-hok/needs-flowmax: "error"*/

const [addMyContextProvider, addMyContext] = getContextHelpers<{
  a: string
  b: number
}>(toObjectKeys(['a', 'b']))
```

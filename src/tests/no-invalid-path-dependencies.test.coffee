path = require 'path'

{ESLintUtils} = require '@typescript-eslint/experimental-utils'

{rules: {'no-invalid-path-dependencies': rule}} = require '..'

ruleTester = new ESLintUtils.RuleTester(
  parser: '@typescript-eslint/parser'
  parserOptions:
    project: './tsconfig.eslint.json'
    tsconfigRootDir: path.join __dirname, '../../src/tests/fixtures'
    sourceType: 'module'
    ecmaFeatures:
      jsx: yes
)

getError = (propPath) ->
  message: "'#{propPath}' is not a valid path into the props object"

tests =
  valid: [
    # simple literal path from same chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addEffect} from 'ad-hok'

      const MyComponent: FC = flowMax(
        addProps(() => ({
          foo: {
            bar: 'bar',
          }
        })),
        addEffect(() => () => {
        }, ['foo.bar']),
        () => null
      )
    '''
  ,
    # non-path dependencies arg
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addEffect} from 'ad-hok'

      const MyComponent: FC = flowMax(
        addProps(() => ({
          foo: {
            bar: 'bar',
          }
        })),
        addEffect(() => () => {
        }, ['foo']),
        () => null
      )
    '''
  ,
    # incoming prop type on component chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addEffect} from 'ad-hok'

      interface Props {
        foo: {
          bar: string
        }
      }

      const MyComponent: FC<Props> = flowMax(
        addEffect(() => () => {
        }, ['foo.bar']),
        () => null
      )
    '''
  ,
    # incoming prop type on ad-hok helper chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addHandlers} from 'ad-hok'

      type AddSomething = <TProps extends {
        foo: {
          bar: string
        }
      }>(props: TProps) => TProps

      const addSomething: AddSomething = flowMax(
        addHandlers({
          doSomething: () => () => {},
        }, ['foo.bar']),
      )
    '''
  ,
    # locally added prop type on ad-hok helper chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps} from 'ad-hok'

      type AddSomething = <TProps>(props: TProps) => TProps

      const addSomething: AddSomething = flowMax(
        addProps(() => ({
          foo: {
            bar: 'bar',
          },
        })),
        addProps({
          incrementA: ({a}) => () => ({
            a: a + 1
          }),
        }, ['foo.bar']),
      )
    '''
  ]
  invalid: [
    # simple literal path from same chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addEffect} from 'ad-hok'

      const MyComponent: FC = flowMax(
        addProps(() => ({
          foo: {
            bar: 'bar',
          }
        })),
        addEffect(() => () => {
        }, ['foo.baz']),
        () => null
      )
    '''
    errors: [getError 'foo.baz']
  ,
    # incoming prop type on component chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addLayoutEffect} from 'ad-hok'

      interface Props {
        foo: {
          bar: string
        }
      }

      const MyComponent: FC<Props> = flowMax(
        addLayoutEffect(() => () => {
        }, ['foo.baz']),
        () => null
      )
    '''
    errors: [getError 'foo.baz']
  ,
    # incoming prop type on ad-hok helper chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps, addHandlers} from 'ad-hok'

      type AddSomething = <TProps extends {
        foo: {
          bar: string
        }
      }>(props: TProps) => TProps

      const addSomething: AddSomething = flowMax(
        addHandlers({
          doSomething: () => () => {},
        }, ['foo.baz']),
      )
    '''
    errors: [getError 'foo.baz']
  ,
    # locally added prop type on ad-hok helper chain
    code: '''
      import React, {FC} from 'react'
      import {flowMax, addProps} from 'ad-hok'

      type AddSomething = <TProps>(props: TProps) => TProps

      const addSomething: AddSomething = flowMax(
        addProps(() => ({
          foo: {
            bar: 'bar',
          },
        })),
        addProps({
          incrementA: ({a}) => () => ({
            a: a + 1
          }),
        }, ['foo.baz']),
      )
    '''
    errors: [getError 'foo.baz']
  ]

ruleTester.run 'no-invalid-path-dependencies', rule, tests

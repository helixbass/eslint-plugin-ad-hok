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
      import {flowMax, addProps} from 'ad-hok'

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
  ]
  invalid: [
    # simple literal path from same chain
    code: '''
      import {flowMax, addProps} from 'ad-hok'

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
  ]

ruleTester.run 'no-invalid-path-dependencies', rule, tests

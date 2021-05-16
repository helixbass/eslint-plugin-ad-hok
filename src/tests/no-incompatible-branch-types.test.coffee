path = require 'path'

{ESLintUtils} = require '@typescript-eslint/experimental-utils'

{rules: {'no-incompatible-branch-types': rule}} = require '..'

ruleTester = new ESLintUtils.RuleTester(
  parser: '@typescript-eslint/parser'
  parserOptions:
    project: './tsconfig.eslint.json'
    tsconfigRootDir: path.join __dirname, '../../src/tests/fixtures'
    sourceType: 'module'
    ecmaFeatures:
      jsx: yes
)

getError = (foundType) ->
  message: "Return type '#{foundType}' is incompatible with flowMax() return type 'ReactElement<any, any> | null'"

tests =
  valid: [
    code: '''
      const MyComponent: FC = flowMax(
        branch(() => true, renderNothing()),
        () => <MyComponent />
      )
    '''
  ,
    code: '''
      const MyComponent: FC = flowMax(
        branch(() => true, returns(() => null)),
        () => <MyComponent />
      )
    '''
  ,
    code: '''
	  declare namespace JSX {
        interface Element {}
      }

      const MyComponent: FC = flowMax(
        branch(() => true, returns(() => <MyComponent />)),
        () => null
      )
    '''
  ,
    code: '''
	  declare namespace JSX {
        interface Element {}
      }

      const MyComponent: FC = flowMax(
        branch(() => true, returns(() => true ? null : <MyComponent />)),
        () => null
      )
    '''
  ]
  invalid: [
    code: '''
      const MyComponent: FC = flowMax(
        branch(() => true, returns(() => 3)),
        () => <MyComponent />
      )
    '''
    errors: [getError 'number']
  ]

ruleTester.run 'no-incompatible-branch-types', rule, tests

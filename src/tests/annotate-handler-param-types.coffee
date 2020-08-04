{rules: {'annotate-handler-param-types': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

errorMissingAnnotation = '''
  Parameter should be annotated to avoid implicit any-typing
'''

tests =
  valid: [
    # ignore .js files
    filename: 'test.js'
    code: '''
      flowMax(
        addHandlers({
          doSomething: () => (b) => {
            b()
          }
        }),
        addStateHandlers(
          {
            count: 0,
          },
          {
            add: ({count}) => (amount) => ({
              count: count + amount
            })
          }
        ),
      )
    '''
  ,
    # ignore .jsx files
    filename: 'test.jsx'
    code: '''
      flowMax(
        addHandlers({
          doSomething: () => (b) => {
            b()
          }
        }),
        addStateHandlers(
          {
            count: 0,
          },
          {
            add: ({count}) => (amount) => ({
              count: count + amount
            })
          }
        ),
      )
    '''
  ,
    filename: 'test.ts'
    code: '''
      flowMax(
        addHandlers({
          doSomething: () => (b: () => void) => {
            b()
          }
        }),
        addStateHandlers(
          {
            count: 0,
          },
          {
            add: ({count}) => (amount: number) => ({
              count: count + amount
            })
          }
        ),
      )
    '''
  ]
  invalid: [
    filename: 'test.ts'
    code: '''
      flowMax(
        addHandlers({
          doSomething: () => (b) => {
            b()
          }
        }),
      )
    '''
    errors: [errorMissingAnnotation]
  ,
    filename: 'test.tsx'
    code: '''
      flowMax(
        addHandlers({
          doSomething: () => (b) => {
            b()
          }
        }),
      )
    '''
    errors: [errorMissingAnnotation]
  ,
    filename: 'test.ts'
    code: '''
      flowMax(
        addStateHandlers(
          {
            count: 0,
          },
          {
            add: ({count}) => (amount) => ({
              count: count + amount
            })
          }
        ),
      )
    '''
    errors: [errorMissingAnnotation]
  ,
    filename: 'test.tsx'
    code: '''
      flowMax(
        addStateHandlers(
          {
            count: 0,
          },
          {
            add: ({count}) => (amount) => ({
              count: count + amount
            })
          }
        ),
      )
    '''
    errors: [errorMissingAnnotation]
  ,
    # complex param
    filename: 'test.tsx'
    code: '''
      flowMax(
        addStateHandlers(
          {
            count: 0,
          },
          {
            add: ({count}) => ({amount}) => ({
              count: count + amount
            })
          }
        ),
      )
    '''
    errors: [errorMissingAnnotation]
  ,
    filename: 'test.ts'
    code: '''
      flowMax(
        addExtendedHandlers({
          doSomething: () => (b) => {
            b()
          }
        }),
      )
    '''
    errors: [errorMissingAnnotation]
  ]

config =
  parser: require.resolve 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign test, config for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'annotate-handler-param-types', rule, tests

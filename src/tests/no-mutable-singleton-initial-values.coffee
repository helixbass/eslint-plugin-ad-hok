{rules: {'no-mutable-singleton-initial-values': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = message: 'Use the callback form for non-primitive initial values'

tests =
  valid: [
    # no initial value provided
    code: '''
      addState('value', 'setValue')
    '''
  ,
    # undefined
    code: '''
      flowMax(
        addState('value', 'setValue', undefined),
        addStateHandlers(
          {
            value: undefined,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # null
    code: '''
      flowMax(
        addState('value', 'setValue', null),
        addStateHandlers(
          {
            value: null,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # number
    code: '''
      flowMax(
        addState('value', 'setValue', 1),
        addStateHandlers(
          {
            value: 1,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # string
    code: '''
      flowMax(
        addState('value', 'setValue', 'abc'),
        addStateHandlers(
          {
            value: 'abc',
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # boolean
    code: '''
      flowMax(
        addState('value', 'setValue', false),
        addStateHandlers(
          {
            value: false,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # complex when using callback
    code: '''
      flowMax(
        addState('value', 'setValue', () => ({a: 1})),
        addStateHandlers(function() {
          return {
            value: new Value(),
          }
        },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # regex
    code: '''
      flowMax(
        addState('value', 'setValue', /abc/),
        addStateHandlers(
          {
            value: /abc/,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # template literal
    code: '''
      flowMax(
        addState('value', 'setValue', `abc${d}`),
        addStateHandlers(
          {
            value: `abc${d}`,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ,
    # tagged template literal
    code: '''
      flowMax(
        addState('value', 'setValue', graphql`abc`),
        addStateHandlers(
          {
            value: graphql`abc`,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
  ]
  invalid: [
    # object literal
    code: '''
      flowMax(
        addState('value', 'setValue', {a: 1}),
        addStateHandlers(
          {
            value: {a: 1},
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
    errors: [error, error]
  ,
    # array literal
    code: '''
      flowMax(
        addState('value', 'setValue', [1]),
        addStateHandlers(
          {
            value: [1],
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
    errors: [error, error]
  ,
    # variable
    code: '''
      flowMax(
        addState('value', 'setValue', a),
        addStateHandlers(
          {
            value: a,
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
    errors: [error, error]
  ,
    # call
    code: '''
      flowMax(
        addState('value', 'setValue', a()),
        addStateHandlers(
          {
            value: a(),
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
    errors: [error, error]
  ,
    # new
    code: '''
      flowMax(
        addState('value', 'setValue', new a()),
        addStateHandlers(
          {
            value: new a(),
          },
          {
            setValue: () => (value) => ({value})
          }
        )
      )
    '''
    errors: [error, error]
  ]

config =
  parser: require.resolve 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign test, config for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'no-mutable-singleton-initial-values', rule, tests

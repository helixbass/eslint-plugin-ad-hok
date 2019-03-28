{rules: {'no-unnecessary-flowmax': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = ->
  message: "Unnecessary use of flowMax()"

tests =
  valid: [
    code: '''
      a = 1
    '''
  ,
    code: '''
      flow(
        addProps({a: 1})
      )
    '''
  ,
    code: '''
      flowMax(
        renderNothing
      )
    '''
  ,
    code: '''
      flowMax(
        returns(1)
      )
    '''
  ,
    code: '''
      flowMax(
        branch(({x}) => x > 1, renderNothing),
      )
    '''
  ,
    code: '''
      flowMax(
        branch(({x}) => x > 1, returns(3)),
      )
    '''
  ,
    code: '''
      flowMax(
        addProps({x: 1}),
        addPropTypes({x: PropTypes.number.isRequired}),
        ({x}) => <div>{x}</div>
      )
    '''
  ]
  invalid: [
    code: '''
      flowMax(
        addProps({x: 1}),
        ({x}) => <div>{x}</div>
      )
    '''
    errors: [error()]
  ,
    code: '''
      flowMax(
        branch(({x}) => x > 1, addProps({x: 3})),
        ({x}) => <div>{x}</div>
      )
    '''
    errors: [error()]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'no-unnecessary-flowmax', rule, tests

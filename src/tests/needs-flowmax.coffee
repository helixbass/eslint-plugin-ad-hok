{rules: {'needs-flowmax': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = (name) ->
  message: "#{name}() only works with flowMax()"

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
        addProps({a: 1})
      )
    '''
  ,
    code: '''
      flowMax(
        renderNothing()
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
      flow(
        branch(({x}) => x > 1, addProps({x: 3})),
      )
    '''
  ,
    code: '''
      flowMax(
        branch(({x}) => x > 1, renderNothing()),
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
      flow(
        renderNothing()
      )
    '''
    errors: [error 'renderNothing']
  ,
    code: '''
      renderNothing()
    '''
    errors: [error 'renderNothing']
  ,
    code: '''
      flow(
        returns(1)
      )
    '''
    errors: [error 'returns']
  ,
    code: '''
      flow(
        branch(({x}) => x > 1, renderNothing()),
      )
    '''
    errors: [error 'renderNothing']
  ,
    code: '''
      flow(
        branch(({x}) => x > 1, returns(3)),
      )
    '''
    errors: [error 'returns']
  ,
    code: '''
      flow(
        addProps({x: 1}),
        addPropTypes({x: PropTypes.number.isRequired}),
        ({x}) => <div>{x}</div>
      )
    '''
    errors: [error 'addPropTypes']
  ,
    code: '''
      flowMax(
        flow(
          branch(({x}) => x > 1, renderNothing()),
        )
      )
    '''
    errors: [error 'renderNothing']
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'needs-flowmax', rule, tests

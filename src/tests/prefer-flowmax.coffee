{rules: {'prefer-flowmax': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = ->
  message: "Use flowMax() instead"

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
    options: ['when-using-unknown-helpers']
  ,
    # don't duplicate needs-flowmax
    code: '''
      flow(
        addPropTypes({a: 1})
      )
    '''
    options: ['when-using-unknown-helpers']
  ,
    code: '''
      flow(
        branchPure(({x}) => x, returns(() => 2))
      )
    '''
    options: ['when-using-unknown-helpers']
  ,
    # functions are ok
    code: '''
      flow(
        ({x}) => x
      )
    '''
    options: ['when-using-unknown-helpers']
  ,
    # whitelist call
    code: '''
      flow(
        addSomethingNonmagic()
      )
    '''
    options: ['when-using-unknown-helpers', whitelist: ['addSomethingNonmagic']]
  ,
    # whitelist call
    code: '''
      flow(
        addSomethingNonmagic
      )
    '''
    options: ['when-using-unknown-helpers', whitelist: ['addSomethingNonmagic']]
  ]
  invalid: [
    # always
    code: '''
      flow(
        addProps({a: 1})
      )
    '''
    # don't fix unless shouldFix
    output: '''
      flow(
        addProps({a: 1})
      )
    '''
    errors: [error()]
    options: ['always']
  ,
    # default is always
    code: '''
      flow(
        addProps({a: 1})
      )
    '''
    errors: [error()]
  ,
    # when-using-unknown-helpers
    code: '''
      flow(
        addSomething()
      )
    '''
    errors: [error()]
    options: ['when-using-unknown-helpers']
  ,
    code: '''
      flow(
        addSomething
      )
    '''
    errors: [error()]
    options: ['when-using-unknown-helpers']
  ,
    # nested flow()
    code: '''
      flow(
        flow(
          addSomething
        )()
      )
    '''
    errors: [error(), error()]
    options: ['when-using-unknown-helpers']
  ,
    # immediately-invoked functions are not ok
    code: '''
      flow(
        (({x}) => doSomethingMagic(x))()
      )
    '''
    errors: [error()]
    options: ['when-using-unknown-helpers']
  ,
    # shouldFix
    code: '''
      flow(
        addProps({a: 1})
      )
    '''
    output: '''
      flowMax(
        addProps({a: 1})
      )
    '''
    errors: [error()]
    options: ['always', shouldFix: yes]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'prefer-flowmax', rule, tests

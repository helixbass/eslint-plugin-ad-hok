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
    options: ['whenUsingUnknownHelpers']
  ,
    # don't duplicate needs-flowmax
    code: '''
      flow(
        addPropTypes({a: 1})
      )
    '''
    options: ['whenUsingUnknownHelpers']
  ,
    code: '''
      flow(
        branchPure(({x}) => x, returns(() => 2))
      )
    '''
    options: ['whenUsingUnknownHelpers']
  ,
    # functions are ok
    code: '''
      flow(
        ({x}) => x
      )
    '''
    options: ['whenUsingUnknownHelpers']
  ,
    # whitelist call
    code: '''
      flow(
        addSomethingNonmagic()
      )
    '''
    options: ['whenUsingUnknownHelpers', whitelist: ['addSomethingNonmagic']]
  ,
    # whitelist call
    code: '''
      flow(
        addSomethingNonmagic
      )
    '''
    options: ['whenUsingUnknownHelpers', whitelist: ['addSomethingNonmagic']]
  ,
    # helperRegex defaults to add.*
    code: '''
      flow(
        something
      )
    '''
    options: ['whenUsingUnknownHelpers']
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
    # whenUsingUnknownHelpers
    code: '''
      flow(
        addSomething()
      )
    '''
    errors: [error()]
    options: ['whenUsingUnknownHelpers']
  ,
    code: '''
      flow(
        addSomething
      )
    '''
    errors: [error()]
    options: ['whenUsingUnknownHelpers']
  ,
    # helperRegex
    code: '''
      flow(
        something
      )
    '''
    errors: [error()]
    options: ['whenUsingUnknownHelpers', {helperRegex: 'add.*|some.*'}]
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
    options: ['whenUsingUnknownHelpers']
  ,
    # immediately-invoked functions are not ok
    code: '''
      flow(
        (({x}) => doSomethingMagic(x))()
      )
    '''
    errors: [error()]
    options: ['whenUsingUnknownHelpers']
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

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
  ,
    # member expression isn't considered potentially magic
    code: '''
      flow(
        something.else
      )
    '''
    options: ['whenUsingUnknownHelpers']
  ,
    # immediately-invoked functions are ok
    code: '''
      flow(
        (({x}) => doSomethingMagic(x))()
      )
    '''
    options: ['whenUsingUnknownHelpers']
  ,
    # ternary is ok unless one of its branches is a helper
    code: '''
      flow(
        y ? doSomething : x => x
      )
    '''
    options: ['whenUsingUnknownHelpers']
  ,
    # recognizes addPropsOnChange()
    code: '''
      flow(
        addPropsOnChange(['x'], ({x}) => ({a: x +1}))
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
  ,
    # ternary isn't ok if one of its branches is a helper
    code: '''
      flow(
        y ? addSomething : x => x
      )
    '''
    errors: [error()]
    options: ['whenUsingUnknownHelpers']
  ,
    # ternary isn't ok if one of its branches is a helper
    code: '''
      flow(
        y ? x => x : addSomething
      )
    '''
    errors: [error()]
    options: ['whenUsingUnknownHelpers']
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'prefer-flowmax', rule, tests

{rules: {'missing-dependencies': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = (propName) ->
  message: """Missing dependency: "#{propName}\""""

tests =
  valid: [
    code: '''
      a = 1
    '''
  ,
    # addProps() no dependencies
    code: '''
      flow(
        addProps(({a}) => ({b: a + 1}))
      )
    '''
  ,
    # addProps() correct dependencies
    code: '''
      flow(
        addProps(({a}) => ({b: a + 1}), ['a'])
      )
    '''
  ,
    # addProps() extra dependency
    code: '''
      flow(
        addProps(({a}) => ({b: a + 1}), ['a', 'c'])
      )
    '''
  ]
  invalid: [
    # addProps() missing dependency
    code: '''
      flow(
        addProps(({a}) => ({b: a + 1}), [])
      )
    '''
    output: '''
      flow(
        addProps(({a}) => ({b: a + 1}), ['a'])
      )
    '''
    errors: [error('a')]
  ,
    # addProps() missing dependency with other dependency
    code: '''
      flow(
        addProps(({a, c}) => ({b: a + c + 1}), ['c'])
      )
    '''
    output: '''
      flow(
        addProps(({a, c}) => ({b: a + c + 1}), ['c', 'a'])
      )
    '''
    errors: [error('a')]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'missing-dependencies', rule, tests

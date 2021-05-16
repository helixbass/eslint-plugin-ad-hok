{rules: {'require-adddisplayname': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = message: 'Set a display name with addDisplayName()'

tests =
  valid: [
    code: '''
      flowMax()
    '''
  ,
    code: '''
      const Component = flowMax(
        addDisplayName('Component'),
        ({b}) => <div>{b}</div>
      )
    '''
  ,
    code: '''
      const Component = flowMax(
        addDisplayName('Something'),
        addProps({b: 2}),
        ({b}) => <div>{b}</div>
      )
    '''
  ,
    # not definitively a "component"
    code: '''
      flowMax(
        ({b}) => <div>{b}</div>
      )
    '''
  ,
    # non-initial addDisplayName()
    code: '''
      const Component = flowMax(
        addProps({b: 2}),
        addDisplayName('Something'),
        ({b}) => <div>{b}</div>
      )
    '''
  ]
  invalid: [
    code: '''
      const Component = flowMax(
        ({b}) => <div>{b}</div>
      )
    '''
    settings:
      'ad-hok/should-fix-importable-names': yes
    output: '''
      const Component = flowMax(
        addDisplayName('Component'), ({b}) => <div>{b}</div>
      )
    '''
    errors: [error]
  ,
    # don't fix unless requested
    code: '''
      const Component = flowMax(
        ({b}) => <div>{b}</div>
      )
    '''
    output: '''
      const Component = flowMax(
        ({b}) => <div>{b}</div>
      )
    '''
    errors: [error]
  ]

config =
  parser: require.resolve 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign test, config for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'require-adddisplayname', rule, tests

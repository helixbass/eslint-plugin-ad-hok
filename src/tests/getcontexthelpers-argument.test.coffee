{rules: {'getcontexthelpers-argument': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

errorMissingArgument = '''
  getContextHelpers() expects a single argument
'''
errorMissingKey = (key) -> """
  Key "#{key}" is present in the context type but not the toObjectKeys() argument
"""
errorUnknownKey = (key) -> """
  Key "#{key}" is not present in the context type
"""

tests =
  valid: [
    # expected usage in .ts
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b']))
    '''
  ,
    # expected usage in .tsx
    filename: 'test.tsx'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b']))
    '''
  ,
    # not using toObjectKeys()
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(foo(['a']))
    '''
  ,
    # passing toObjectKeys() a non-array
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(someKeys))
    '''
  ,
    # ordered differently
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['b', 'a']))
    '''
  ,
    # not flagged for .js
    filename: 'test.js'
    code: '''
      getContextHelpers(toObjectKeys(['a', 'b']))
    '''
  ,
    # not flagged for .jsx
    filename: 'test.jsx'
    code: '''
      getContextHelpers(toObjectKeys(['a', 'b']))
    '''
  ,
    # doesn't flag missing argument without should-fix-importable-names setting
    # (because Typescript will flag it)
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>()
    '''
  ]
  invalid: [
    # flagged for .ts
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a']))
    '''
    output: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b']))
    '''
    errors: [errorMissingKey 'b']
  ,
    # flagged for .tsx
    filename: 'test.tsx'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a']))
    '''
    output: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b']))
    '''
    errors: [errorMissingKey 'b']
  ,
    # flag + autofix missing argument with should-fix-importable-names setting
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>()
    '''
    output: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b']))
    '''
    errors: [errorMissingArgument]
    settings:
      'ad-hok/should-fix-importable-names': yes
  ,
    # extra keys
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'c', 'b']))
    '''
    output: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b']))
    '''
    errors: [errorUnknownKey 'c']
  ,
    # extra key last
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b', 'c']))
    '''
    output: '''
      getContextHelpers<{
        a: string
        b: number
      }>(toObjectKeys(['a', 'b', ]))
    '''
    errors: [errorUnknownKey 'c']
  ,
    # empty array
    filename: 'test.ts'
    code: '''
      getContextHelpers<{
        a: string
      }>(toObjectKeys([]))
    '''
    output: '''
      getContextHelpers<{
        a: string
      }>(toObjectKeys(['a']))
    '''
    errors: [errorMissingKey 'a']
  ]

config =
  parser: require.resolve '@typescript-eslint/parser'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign test, config for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'getcontexthelpers-argument', rule, tests

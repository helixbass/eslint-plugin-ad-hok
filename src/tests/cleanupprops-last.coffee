{rules: {'cleanupprops-last': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

errorNonFinal = """
  cleanupProps() is type-unsafe unless last in chain
"""

tests =
  valid: [
    # expected usage in .ts
    filename: 'test.ts'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
      )
    '''
  ,
    # expected usage in .tsx
    filename: 'test.tsx'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
      )
    '''
  ,
    # non-final removeProps()
    filename: 'test.ts'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        removeProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
  ,
    # not flagged for .js
    filename: 'test.js'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
  ,
    # not flagged for .jsx
    filename: 'test.jsx'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
  ,
    # not flagged if not in flow()/flowMax(
    filename: 'test.ts'
    code: '''
      const addSomething = compose(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
    errors: [errorNonFinal]
  ]
  invalid: [
    # flagged for .ts
    filename: 'test.ts'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
    errors: [errorNonFinal]
  ,
    # flagged for .tsx
    filename: 'test.tsx'
    code: '''
      const addSomething = flowMax(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
    errors: [errorNonFinal]
  ,
    # flagged for flow()
    filename: 'test.tsx'
    code: '''
      const addSomething = flow(
        addProps(() => ({
          a: 1
        })),
        addProps(({a}) => ({
          b: a + 1
        })),
        cleanupProps(['a']),
        addProps({
          c: 2
        })
      )
    '''
    errors: [errorNonFinal]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'cleanupprops-last', rule, tests

{rules: {dependencies: rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

errorMissing = (name) ->
  message: """
    Missing dependency "#{name}"
  """

errorUnnecessary = (name) ->
  message: """
    Unnecessary dependency "#{name}"
  """

tests =
  valid: [
    # no dependencies argument
    code: '''
      flow(
        addProps(({a, b}) => ({
          c
        })),
        addEffect(({a}) => () => {
          c()
        }),
        addLayoutEffect(({a}) => () => {
          c()
        }),
        addHandlers({
          a: ({b}) => () => {
            c()
          }
        }),
        addStateHandlers(
          {a: 1},
          {b: (_, {c}) => () => ({a: 2})}
        )
      )
    '''
  ,
    # correct dependencies argument
    code: '''
      flow(
        addProps(({a, b}) => ({
          c
        }), ['a', 'b']),
        addEffect(({a}) => () => {
          c()
        }, ['a']),
        addLayoutEffect(({a}) => () => {
          c()
        }, ['a']),
        addHandlers({
          a: ({b}) => () => {
            c()
          }
        }, ['b']),
        addStateHandlers(
          {a: 1},
          {b: (_, {c}) => () => ({a: 2})},
          ['c']
        )
      )
    '''
  ,
    # spread props
    code: '''
      flow(
        addProps(({a, b, ...c}) => ({
          c
        }), ['a']),
        addEffect(({a, b, ...c}) => () => {
          c()
        }, ['a']),
        addLayoutEffect(({a, b, ...c}) => () => {
          c()
        }, ['a']),
        addHandlers({
          a: ({b, c, ...d}) => () => {
            c()
          }
        }, ['b']),
        addStateHandlers(
          {a: 1},
          {b: (_, {c, d, ...e}) => () => ({a: 2})},
          ['c']
        )
      )
    '''
  ,
    # path dependencies
    code: '''
      flow(
        addProps(({a: {c}, b: {d}}) => ({
          c
        }), ['a.c', 'b']),
        addEffect(({a: {b}}) => () => {
          c()
        }, ['a.b']),
        addLayoutEffect(({a: {b}}) => () => {
          c()
        }, ['a.b']),
        addHandlers({
          a: ({b: {c}}) => () => {
            c()
          }
        }, ['b.c']),
        addStateHandlers(
          {a: 1},
          {b: (_, {c: {d}}) => () => ({a: 2})},
          ['c.d']
        )
      )
    '''
  ,
    # callback-style dependencies
    code: '''
      flow(
        addProps(({a, b}) => ({
          c
        }), (prevProps, props) => true),
        addEffect(({a}) => () => {
          c()
        }, (prevProps, props) => true),
        addLayoutEffect(({a}) => () => {
          c()
        }, (prevProps, props) => true),
        addHandlers({
          a: ({b}) => () => {
            c()
          }
        }, (prevProps, props) => true),
        addStateHandlers(
          {a: 1},
          {b: (_, {c}) => () => ({a: 2})},
          (prevProps, props) => true
        )
      )
    '''
  ,
    # multiple path dependencies
    code: '''
      flowMax(
        addProps(({a: {b, c: {d, e}}}) => ({
          c
        }), ['a.b', 'a.c.d', 'a.c.e']),
      )
    '''
  ,
    # multiple path dependencies nested parent
    code: '''
      flowMax(
        addProps(({a: {b, c: {d, e}}}) => ({
          c
        }), ['a.b', 'a.c']),
      )
    '''
  ,
    # multiple path dependencies overall parent
    code: '''
      flowMax(
        addProps(({a: {b, c: {d, e}}}) => ({
          c
        }), ['a']),
      )
    '''
  ,
    # destructured renaming
    code: '''
      flowMax(
        addProps(({a: {b: c}}) => ({
          c
        }), ['a.b']),
      )
    '''
  ]
  invalid: [
    # missing dependencies
    code: '''
      addProps(({a}) => ({
        b: a
      }), [])
    '''
    errors: [errorMissing 'a']
  ,
    code: '''
      addEffect(({a}) => () => {
        a()
      }, [])
    '''
    errors: [errorMissing 'a']
  ,
    code: '''
      addLayoutEffect(({a}) => () => {
        a()
      }, [])
    '''
    errors: [errorMissing 'a']
  ,
    code: '''
      addStateHandlers(
        {a: 1},
        {b: (_, {c, d: {e}}) => () => ({a: c + d})},
        ['d.e']
      )
    '''
    errors: [errorMissing 'c']
  ,
    code: '''
      addHandlers(
        {
          a: ({b, c}) => () => {
            b()
          }
        },
        ['b']
      )
    '''
    errors: [errorMissing 'c']
  ,
    # unnecessary dependencies
    code: '''
      addProps(() => ({
        b: 1
      }), ['b'])
    '''
    errors: [errorUnnecessary 'b']
  ,
    code: '''
      addEffect(({a}) => () => {
        a()
      }, ['a', 'b'])
    '''
    errors: [errorUnnecessary 'b']
  ,
    code: '''
      addLayoutEffect(({a}) => () => {
        a()
      }, ['a', 'b'])
    '''
    errors: [errorUnnecessary 'b']
  ,
    code: '''
      addStateHandlers(
        {a: 1},
        {b: (_, {c, d}) => () => ({a: c + d})},
        ['e.f', 'd', 'c']
      )
    '''
    errors: [errorUnnecessary 'e.f']
  ,
    code: '''
      addHandlers(
        {
          a: ({b, c}) => () => {
            b()
          }
        },
        ['b', 'c', 'd']
      )
    '''
    errors: [errorUnnecessary 'd']
  ,
    # unnecessary and missing dependencies
    code: '''
      addProps(({c}) => ({
        b: 1
      }), ['b'])
    '''
    errors: [
      errorMissing 'c'
      errorUnnecessary 'b'
    ]
  ,
    # aggregates handlers
    code: '''
      addHandlers(
        {
          a: ({b}) => () => {
            b()
          },
          c: ({d}) => () => {
            d()
          }
        },
        []
      )
    '''
    errors: [
      errorMissing 'b'
      errorMissing 'd'
    ]
  ,
    code: '''
      addStateHandlers(
        {a: 1},
        {
          b: (_, {c, d}) => () => ({a: 2}),
          e: (_, {f}) => () => ({a: 3}),
        },
        ['d']
      )
    '''
    errors: [
      errorMissing 'c'
      errorMissing 'f'
    ]
  ,
    # wrong nested dependencies
    code: '''
      addEffect(({a: {b}}) => () => {
        a()
      }, ['a.c'])
    '''
    errors: [errorMissing('a.b'), errorUnnecessary('a.c')]
  ,
    code: '''
      addEffect(({a: {b}}) => () => {
        a()
      }, ['a.b', 'a.c'])
    '''
    errors: [errorUnnecessary('a.c')]
  ,
    code: '''
      addEffect(({a: {b}}) => () => {
        a()
      }, ['a.b.c'])
    '''
    errors: [errorMissing('a.b'), errorUnnecessary('a.b.c')]
  ,
    code: '''
      addEffect(({a: {b, c}}) => () => {
        a()
      }, ['a.b'])
    '''
    errors: [errorMissing('a.c')]
  ,
    code: '''
      addEffect(({a: {b, c: {d}}}) => () => {
        a()
      }, ['a.b'])
    '''
    errors: [errorMissing('a.c.d')]
  ,
    code: '''
      addEffect(({a: {b: c}}) => () => {
        a()
      }, ['a.c'])
    '''
    errors: [errorMissing('a.b'), errorUnnecessary('a.c')]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'dependencies', rule, tests

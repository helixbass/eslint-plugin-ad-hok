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
      const addSomething = renderNothing()
    '''
  ,
    code: '''
      const addSomething = branch(
        (({x}) => x, renderNothing())
      )
    '''
  ,
    code: '''
      const addSomething = addWrapper(
        ({render}) => <>{render()}</>
      )
    '''
  ,
    code: '''
      const addSomething = addWrapperHOC(
        ({render}) => <>{render()}</>
      )
    '''
  ,
    code: '''
      const addSomething = () => {
        addPropTypes({x: PropTypes.string})
      }
    '''
  ,
    code: '''
      flow(
        branchPure(({x}) => x, a)
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
      flow(
        returns(() => 1)
      )
    '''
    # don't fix unless should-fix-flow-flowmax is set
    output: '''
      flow(
        returns(() => 1)
      )
    '''
    errors: [error 'returns']
  ,
    code: '''
      flow(
        branch(({x}) => x > 1, renderNothing()),
      )
    '''
    errors: [error 'branch']
  ,
    code: '''
      flow(
        branch(({x}) => x > 1, returns(() => 3)),
      )
    '''
    errors: [error 'branch']
  ,
    code: '''
      flow(
        branch(({x}) => x > 1, returns(() => 3)),
      )
    '''
    errors: [error 'branch']
  ,
    # branch() is always magic
    code: '''
      flow(
        branch(({x}) => x > 1, addProps({x: 3})),
      )
    '''
    errors: [error 'branch']
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
    errors: [error 'branch']
  ,
    # catch returns() inside branchPure()
    code: '''
      flow(
        branchPure(({x}) => x, returns(() => 1))
      )
    '''
    errors: [error 'returns']
  ,
    # addWrapper()
    code: '''
      flow(
        addWrapper(({render}) => <div>{render()}</div>)
      )
    '''
    errors: [error 'addWrapper']
  ,
    # addWrapperHOC()
    code: '''
      flow(
        addWrapperHOC(withNavigation)
      )
    '''
    errors: [error 'addWrapperHOC']
  ,
    # nested flowMax()
    code: '''
      flow(
        flowMax(something())
      )
    '''
    errors: [error 'flowMax']
  ,
    code: '''
      flow(
        returns(() => 1)
      )
    '''
    output: '''
      flowMax(
        returns(() => 1)
      )
    '''
    errors: [error 'returns']
    settings:
      'ad-hok/should-fix-flow-flowmax': yes
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'needs-flowmax', rule, tests

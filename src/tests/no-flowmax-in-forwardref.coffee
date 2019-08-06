{rules: {'no-flowmax-in-forwardref': rule}} = require '..'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error =
  message: "Avoid using flowMax() within React.forwardRef()"

tests =
  valid: [
    code: '''
      flowMax()
    '''
  ,
    code: '''
      const HoistedComponent = flowMax(
        addWrapper(({render, forwardedRef}) => <div ref={forwardedRef}>{render()}</div>),
        ({foo}) => <span>{foo}</span>
      )

      const Component = React.forwardRef((props, ref) =>
        <HoistedComponent {...props} forwardedRef={ref} />
      )
    '''
  ,
    code: '''
      const Foo = forwardRef((props, ref) =>
        flow(
          addProps(({foo}) => ({bar: foo + 1})),
          ({bar, ref}) => <div ref={ref}>{bar}</div>
        )({...props, ref})
      )
    '''
  ]
  invalid: [
    code: '''
      export default forwardRef((props, ref) =>
        callWith({...props, ref})(
          flowMax(
            addProps({foo: 'bar'}),
            ({foo, ref}) =>
              <div ref={ref}>{foo}</div>
          )
        )
      )
    '''
    errors: [error]
  ,
    code: '''
      const Foo = React.forwardRef((props, forwardedRef) => {
        const InnerFoo = flowMax(
          ({bar, forwardedRef}) =>
            <div ref={forwardedRef}>{bar}</div>
        )
        return <InnerFoo {...props} forwardedRef={forwardedRef} />
      })
    '''
    errors: [error]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'no-flowmax-in-forwardref', rule, tests

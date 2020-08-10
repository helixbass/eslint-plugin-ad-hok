{isFunctionNode, isUndefinedNode} = require '../util'

module.exports =
  meta:
    docs:
      description:
        'Flag potentially mutable initial values that are shared across component instances'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    CallExpression: (node) ->
      {callee, arguments: args} = node
      return unless (
        callee?.type is 'Identifier' and
        callee.name in ['addState', 'addStateHandlers']
      )

      if callee.name is 'addState'
        initialValue = args[2]
        return if not initialValue? or isFunctionNode initialValue
        initialValues = [initialValue]
      else
        initialValuesObject = args[0]
        return unless initialValuesObject?.type is 'ObjectExpression'
        initialValues =
          property.value for property in initialValuesObject.properties

      for initialValue in initialValues
        continue if initialValue.type in [
          'Literal'
          'TemplateLiteral'
          'TaggedTemplateExpression'
        ]
        continue if isUndefinedNode initialValue

        context.report
          node: initialValue
          message: '''
            Use the callback form for non-primitive initial values
          '''

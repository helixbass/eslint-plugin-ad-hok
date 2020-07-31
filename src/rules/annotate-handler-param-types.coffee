{isTypescript} = require '../util'

helperNames = [
  'addHandlers'
  'addStateHandlers'
]

module.exports =
  meta:
    docs:
      description: 'Flag handler params without explicit type annotations'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    return {} unless isTypescript context

    CallExpression: (node) ->
      {callee, arguments: args} = node
      return unless callee?.type is 'Identifier'
      {name} = callee
      return unless name in helperNames

      switch name
        when 'addHandlers'
          handlers = args[0]
        when 'addStateHandlers'
          handlers = args[1]

      return unless handlers?.type is 'ObjectExpression'

      for {value: outerFunction} in handlers.properties
        continue unless outerFunction.type is 'ArrowFunctionExpression'
        {body: innerFunction} = outerFunction
        continue unless innerFunction.type is 'ArrowFunctionExpression'
        for param in innerFunction.params
          continue if param.typeAnnotation
          context.report {
            node
            message: """
              Parameter should be annotated to avoid implicit any-typing
            """
          }

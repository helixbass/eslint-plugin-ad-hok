{last} = require 'lodash'

{isTypescript, isFlowOrFlowMax} = require '../util'

module.exports =
  meta:
    docs:
      description: "Flag uses of cleanupProps() that aren't last in a chain"
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    return {} unless isTypescript context

    CallExpression: (node) ->
      {callee, parent} = node
      return unless callee?.type is 'Identifier' and callee.name is 'cleanupProps'

      return unless isFlowOrFlowMax parent
      {arguments: args} = parent
      return if node is last args

      context.report {
        node
        message: """
          cleanupProps() is type-unsafe unless last in chain, consider removeProps()
        """
      }

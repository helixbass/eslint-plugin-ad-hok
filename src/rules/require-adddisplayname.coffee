{shouldFix, getAddDisplayNameFixer} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag flowMax() components without addDisplayName()'
      category: 'Possible Errors'
      recommended: yes
    schema: []
    fixable: 'code'

  create: (context) ->
    report = (node) ->
      context.report {
        node,
        message: 'Set a display name with addDisplayName()'
        fix:
          if shouldFix {context}
            getAddDisplayNameFixer {node, context}
          else
            null
      }

    "CallExpression[callee.name='flowMax']":
      (node) ->
        return unless node.arguments?.length
        return unless do ->
          return no unless node.parent?.type is 'VariableDeclarator'
          return no unless node.parent.id.type is 'Identifier'
          return no unless /^[A-Z]/.test node.parent.id.name
          yes
        for argument in node.arguments
          if argument?.type is 'CallExpression' and argument.callee.type is 'Identifier' and argument.callee.name is 'addDisplayName'
            return

        report node

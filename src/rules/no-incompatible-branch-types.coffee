{isTypescript} = require '../util'

module.exports =
  meta:
    docs:
      description:
        'Flag incompatible early-return types in branch()/branchPure()'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    return {} unless isTypescript context

    {parserServices} = context
    return {} unless parserServices?.hasFullTypeInformation

    CallExpression: (node) ->
      {callee, parent} = node
      return unless (
        callee?.type is 'Identifier' and
        callee.name in ['renderNothing', 'returns']
      )

      return unless (
        parent.type is 'CallExpression' and
        parent.callee.type is 'Identifier' and
        parent.callee.name in ['branch', 'branchPure']
      )

      context.report {
        node
        message: '''
          cleanupProps() is type-unsafe unless last in chain, consider removeProps()
        '''
      }

{
  isFlow
  isMagic
  isBranchPure
  getFlowToFlowMaxFixer
  shouldFix
} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag calls that are missing containing flowMax()'
      category: 'Possible Errors'
      recommended: yes
    schema: []
    fixable: 'code'

  create: (context) ->
    report = (node, magicName) ->
      context.report {
        node
        message: "#{magicName}() only works with flowMax()"
        fix: if shouldFix {context}
          getFlowToFlowMaxFixer {node, context}
        else
          null
      }

    CallExpression: (node) ->
      return unless isFlow node
      for argument in node.arguments
        if isMagic argument
          report node, argument.callee.name
        if isBranchPure argument
          for branchPureArgument in argument.arguments
            if isMagic branchPureArgument
              report node, branchPureArgument.callee.name

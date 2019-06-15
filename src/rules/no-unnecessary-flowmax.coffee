{isFlowMax, nonmagicHelperNames, isFunction, isBranchPure} = require '../util'

isNonmagic = (node) ->
  return yes unless node?
  return yes if isFunction node
  {callee} = node
  return no unless callee?.type is 'Identifier'
  callee.name in nonmagicHelperNames

module.exports =
  meta:
    docs:
      description: 'Flag unnecessary uses of flowMax()'
      category: 'General'
      recommended: yes
    schema: []

  create: (context) ->
    CallExpression: (node) ->
      return unless isFlowMax node
      for argument in node.arguments
        return unless isNonmagic argument
        if isBranchPure argument
          for branchPureArgument in argument.arguments
            return unless isNonmagic branchPureArgument
      context.report node, "Unnecessary use of flowMax()"

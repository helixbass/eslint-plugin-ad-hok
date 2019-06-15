{isFlow, isMagic, isBranchPure} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag calls that are missing containing flowMax()'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    CallExpression: (node) ->
      return unless isFlow node
      for argument in node.arguments
        if isMagic argument
          context.report node, "#{argument.callee.name}() only works with flowMax()"
        if isBranchPure argument
          for branchPureArgument in argument.arguments
            if isMagic branchPureArgument
              context.report node, "#{branchPureArgument.callee.name}() only works with flowMax()"

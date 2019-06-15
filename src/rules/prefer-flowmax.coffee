{isFlow, isMagic, isBranchPure, getFlowToFlowMaxFixer, isNonmagicHelper, isFunction} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag flow() calls that could be converted to flowMax()'
      category: 'Possible Errors'
      recommended: yes
    schema: [
      enum: ['always', 'whenUsingUnknownHelpers']
    ,
      type: 'object'
      properties:
        shouldFix:
          type: 'boolean'
        whitelist:
          type: 'array'
          items:
            type: 'string'
      additionalProperties: no
    ]
    fixable: 'code'

  create: (context) ->
    variant = context.options[0] ? 'always'
    {whitelist = [], shouldFix} = context.options[1] ? {}

    report = (node) ->
      context.report {
        node
        message: "Use flowMax() instead"
        fix:
          if shouldFix
            getFlowToFlowMaxFixer {node, context}
          else
            null
      }

    isWhitelisted = (argument) ->
      return no unless argument?
      argument.callee?.name in whitelist or argument.name in whitelist

    CallExpression: (node) ->
      return unless isFlow node
      if variant is 'always'
        return report node

      checkArgument = (argument) ->
        # don't overlap with needs-flowmax
        if isMagic argument
          return shouldReturn: yes
        if isNonmagicHelper argument
          if isBranchPure argument
            for branchPureArgument in argument.arguments
              {shouldReturn} = checkArgument branchPureArgument
              if shouldReturn
                return shouldReturn: yes
          return {}
        if isFunction argument
          return {}
        if isWhitelisted argument
          return {}
        report node
        return shouldReturn: yes

      for argument in node.arguments
        {shouldReturn} = checkArgument argument
        return if shouldReturn

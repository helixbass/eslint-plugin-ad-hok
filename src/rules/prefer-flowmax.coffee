{isFlow, isMagic, isBranchPure, getFlowToFlowMaxFixer, isNonmagicHelper, isFunction, shouldFix} = require '../util'

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
        whitelist:
          type: 'array'
          items:
            type: 'string'
        helperRegex:
          type: 'string'
      additionalProperties: no
    ]
    fixable: 'code'

  create: (context) ->
    variant = context.options[0] ? 'always'
    {whitelist = [], helperRegex = 'add.*'} = context.options[1] ? {}

    isWhitelisted = (name) ->
      name in whitelist

    regexMatchingHelpers = new RegExp(helperRegex)
    isPotentiallyMagicCustomHelper = (argument) ->
      return no unless argument?
      name = argument.callee?.name ? argument.name
      return no unless name?
      return no if isWhitelisted name
      regexMatchingHelpers.test name

    isHelper = (argument) ->
      return no unless argument?
      return yes if argument.type is 'Identifier'
      return no unless argument.type is 'CallExpression'
      argument.callee.type is 'Identifier'

    report = (node) ->
      context.report {
        node
        message: "Use flowMax() instead"
        fix:
          if shouldFix {context}
            getFlowToFlowMaxFixer {node, context}
          else
            null
      }

    CallExpression: (node) ->
      return unless isFlow node
      if variant is 'always'
        return report node

      checkArgument = (argument) ->
        return {} unless argument?
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
        if isPotentiallyMagicCustomHelper argument
          report node
          return shouldReturn: yes
        if argument.type is 'ConditionalExpression'
          if isPotentiallyMagicCustomHelper(argument.consequent) or isPotentiallyMagicCustomHelper(argument.alternate)
            report node
            return shouldReturn: yes
        return {}

      for argument in node.arguments
        {shouldReturn} = checkArgument argument
        return if shouldReturn

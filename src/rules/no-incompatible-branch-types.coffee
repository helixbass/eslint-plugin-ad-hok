module.exports =
  meta:
    docs:
      description:
        'Flag incompatible early-return types in branch()/branchPure()'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    {parserServices} = context
    return {} unless parserServices?.hasFullTypeInformation

    typeChecker = parserServices.program.getTypeChecker()

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

      isReturns = callee.name is 'returns'
      if isReturns
        {arguments: [returnsCallbackNode]} = node
        return unless returnsCallbackNode?

        tsReturnsCallbackNode = parserServices.esTreeNodeToTSNodeMap.get(
          returnsCallbackNode
        )
        tsReturnsCallbackType = typeChecker.getTypeAtLocation(
          tsReturnsCallbackNode
        )
        [signature] = typeChecker.getSignaturesOfType(
          tsReturnsCallbackType
          0 ### ts.SignatureKind.Call ###
        )
        return unless signature?
        returnType = typeChecker.getReturnTypeOfSignature signature

        console.log {returnType}

      context.report {
        node
        message: '''
          cleanupProps() is type-unsafe unless last in chain, consider removeProps()
        '''
      }

ts = require 'typescript'

# getSourceFileOfNode = (tsNode) ->
#   while node and node.kind isnt ts.SyntaxKind.SourceFile
#     node = node.parent
#   node

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
        callee.name in [### 'renderNothing', ### 'returns']
      )

      return unless (
        parent.type is 'CallExpression' and
        parent.callee.type is 'Identifier' and
        parent.callee.name in ['branch' ### , 'branchPure'###]
      )

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
        ts.SignatureKind.Call
      )
      return unless signature?
      returnType = typeChecker.getReturnTypeOfSignature signature
      returnTypeString = typeChecker.typeToString returnType
      return if returnTypeString in ['null', 'Element']

      # tsProgram = parserServices.program
      # sourceFile = getSourceFileOfNode tsReturnsCallbackNode
      # diagnostics = tsProgram.getSemanticDiagnostics sourceFile

      context.report {
        node
        message: """
          Return type '#{returnTypeString}' is incompatible with flowMax() return type 'ReactElement<any, any> | null'
        """
      }

# ts = require 'typescript'
{isString, includes} = require 'lodash'

# getSourceFileOfNode = (tsNode) ->
#   while tsNode and tsNode.kind isnt ts.SyntaxKind.SourceFile
#     tsNode = tsNode.parent
#   tsNode

module.exports =
  meta:
    docs:
      description:
        'Flag invalid path-style dependencies arguments'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    {parserServices} = context
    return {} unless parserServices?.hasFullTypeInformation

    typeChecker = parserServices.program.getTypeChecker()

    CallExpression: (node) ->
      {callee} = node
      return unless (
        callee?.type is 'Identifier' and callee.name in ['addEffect']
      )
      {arguments: [, dependenciesArg]} = node
      return unless dependenciesArg?.type is 'ArrayExpression'
      pathDependencies = dependenciesArg.elements.flatMap (dependencyArg) ->
        return [] unless dependencyArg?.type is 'Literal'
        {value: dependencyPath} = dependencyArg
        return [] unless (
          isString(dependencyPath) and includes dependencyPath, '.'
        )
        [dependencyPath]
      # console.log {pathDependencies}
      return unless pathDependencies.length

      # tsProgram = parserServices.program
      # sourceFile = getSourceFileOfNode(
      #   parserServices.esTreeNodeToTSNodeMap.get node
      # )
      # diagnostics = tsProgram.getSemanticDiagnostics sourceFile
      # console.log {diagnostics}

      for pathDependency in pathDependencies
        tsChainStepNode = parserServices.esTreeNodeToTSNodeMap.get node
        chainStepType = typeChecker.getContextualType tsChainStepNode
        [signature] = chainStepType.getCallSignatures()
        # console.log {signature}
        return unless signature?
        propsParam = signature.getParameters()[0]
        # console.log {propsParam}
        return unless propsParam?.valueDeclaration
        propsParamType = typeChecker.getTypeOfSymbolAtLocation(
          propsParam
          propsParam.valueDeclaration
        )
        # console.log {propsParamType}
        return unless propsParamType?
        pathChunks = pathDependency.split '.'
        currentObjectType = propsParamType
        while pathChunks.length
          currentPathChunk = pathChunks.shift()
          foundProperty = currentObjectType.getProperty currentPathChunk
          # console.log {
          #   pathChunks
          #   currentObjectType
          #   foundProperty
          #   currentPathChunk
          # }
          unless foundProperty?
            context.report {
              node
              message: """
                '#{pathDependency}' is not a valid path into the props object
              """
            }
            return
          # console.log {foundProperty}
          currentObjectType =
            foundProperty.type ? (
              if foundProperty.valueDeclaration
                typeChecker.getTypeOfSymbolAtLocation(
                  foundProperty
                  foundProperty.valueDeclaration
                )
              else
                null
            )
          return unless currentObjectType?

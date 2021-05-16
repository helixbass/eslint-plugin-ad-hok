# ts = require 'typescript'
{isString, includes, keys} = require 'lodash'

# getSourceFileOfNode = (tsNode) ->
#   while tsNode and tsNode.kind isnt ts.SyntaxKind.SourceFile
#     tsNode = tsNode.parent
#   tsNode

DEPENDENCIES_ARGUMENT_POSITIONS =
  addProps: 1
  addHandlers: 1
  addEffect: 1
  addLayoutEffect: 1
HELPER_NAMES_WITH_DEPENDENCIES_ARGUMENT = keys DEPENDENCIES_ARGUMENT_POSITIONS

NUMBER_REGEX = /^\d+$/

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
        callee?.type is 'Identifier' and
        callee.name in HELPER_NAMES_WITH_DEPENDENCIES_ARGUMENT
      )
      dependenciesArg = node.arguments[
        DEPENDENCIES_ARGUMENT_POSITIONS[callee.name]
      ]
      return unless dependenciesArg?.type is 'ArrayExpression'
      pathDependencies = dependenciesArg.elements.flatMap (dependencyArg) ->
        return [] unless dependencyArg?.type is 'Literal'
        {value: dependencyPath} = dependencyArg
        return [] unless (
          isString(dependencyPath) and includes dependencyPath, '.'
        )
        [dependencyArg]
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
        pathChunks = pathDependency.value.split '.'
        currentObjectType = propsParamType
        while pathChunks.length
          currentPathChunk = pathChunks.shift()
          return if NUMBER_REGEX.test currentPathChunk
          foundProperty = currentObjectType.getProperty currentPathChunk
          # console.log {
          #   pathChunks
          #   currentObjectType
          #   foundProperty
          #   currentPathChunk
          # }
          unless foundProperty?
            context.report
              node: pathDependency
              message: """
                '#{
                pathDependency.value
              }' is not a valid path into the props object
              """
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

{startsWith} = require 'lodash'

getFunctionParam = (argumentNum) -> (func) ->
  return unless func?.type is 'ArrowFunctionExpression'
  func.params[argumentNum] ?
    type: 'ObjectPattern'
    properties: []

module.exports =
  meta:
    docs:
      description: 'Flag missing/unnecessary dependencies'
      category: 'Possible Errors'
      recommended: yes
    schema: [
      type: 'object'
      properties:
        effects:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    {effects = yes} = context.options[0] ? {}

    helperNames = ['addProps', 'addHandlers', 'addStateHandlers']
    helperNames = [...helperNames, 'addEffect', 'addLayoutEffect'] if effects

    reportUnused = (node) ->
      context.report {
        node
        message: """
          "#{
          node.value
        }" is not used so should not be included in the dependencies array
        """
      }

    reportMissing = (node, name) ->
      context.report {
        node
        message: """
          Used prop "#{name}" is missing from the dependencies array
        """
      }

    CallExpression: (node) ->
      {callee, arguments: args} = node
      return unless callee?.type is 'Identifier'
      {name} = callee
      return unless name in helperNames

      switch name
        when 'addHandlers'
          dependencies = args[1]
          handlers = args[0]
          return unless handlers?.type is 'ObjectExpression'
          dependencyParams = for handlerProperty in handlers.properties
            {value: handlerFunction} = handlerProperty
            getFunctionParam(0) handlerFunction
        when 'addStateHandlers'
          dependencies = args[2]
          handlers = args[1]
          return unless handlers?.type is 'ObjectExpression'
          dependencyParams = for handlerProperty in handlers.properties
            {value: handlerFunction} = handlerProperty
            getFunctionParam(1) handlerFunction
        else
          dependencies = args[1]
          dependencyParams = [getFunctionParam(0) args[0]]

      return unless (
        dependencies?.type is 'ArrayExpression' and dependencyParams?.length
      )
      usedDependencies = []
      captureUsedDependencies = ({property, pathPrefix}) ->
        return unless property.type is 'Property'
        {key, value} = property
        return unless key.type is 'Identifier'
        path = "#{pathPrefix}#{if pathPrefix then '.' else ''}#{key.name}"
        if value.type is 'Identifier'
          usedDependencies.push path unless path in usedDependencies
          return yes
        return unless value.type is 'ObjectPattern'
        for subProperty in value.properties
          ret = captureUsedDependencies(
            property: subProperty
            pathPrefix: path
          )
          return unless ret
        return yes

      for dependencyParam in dependencyParams
        return unless dependencyParam?.type is 'ObjectPattern'
        for property in dependencyParam.properties
          ret = captureUsedDependencies {
            property
            pathPrefix: ''
          }
          return unless ret?

      for dependency in dependencies.elements
        return unless dependency.type is 'Literal'
        {value: dependencyPath} = dependency
        unless (
          # eslint-disable-next-line coffee/no-loop-func
          usedDependencies.find((usedDependency) ->
            startsWith usedDependency, dependencyPath
          )
        )
          reportUnused dependency

      dependencyPaths =
        dependency.value for dependency in dependencies.elements
      for usedDependency in usedDependencies
        unless (
          # eslint-disable-next-line coffee/no-loop-func, coffee/no-shadow
          dependencyPaths.find((dependencyPath) ->
            startsWith usedDependency, dependencyPath
          )
        )
          reportMissing node, usedDependency

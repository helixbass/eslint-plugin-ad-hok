helperNames = [
  'addProps'
  'addEffect'
  'addLayoutEffect'
  'addHandlers'
  'addStateHandlers'
]

getFunctionParam = (argumentNum) -> (func) ->
  return unless func?.type is 'ArrowFunctionExpression'
  func.params[argumentNum] ? {
    type: 'ObjectPattern'
    properties: []
  }

module.exports =
  meta:
    docs:
      description: 'Flag missing/unnecessary dependencies'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    reportUnused = (node) ->
      context.report {
        node
        message: """
          Unnecessary dependency "#{node.value}"
        """
      }

    reportMissing = (node, name) ->
      context.report {
        node
        message: """
          Missing dependency "#{name}"
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
          dependencyParams =
            for property in handlers.properties
              {value} = property
              getFunctionParam(0) value
        when 'addStateHandlers'
          dependencies = args[2]
          handlers = args[1]
          return unless handlers?.type is 'ObjectExpression'
          dependencyParams =
            for property in handlers.properties
              {value} = property
              getFunctionParam(1) value
        else
          dependencies = args[1]
          dependencyParams = [getFunctionParam(0) args[0]]

      return unless dependencies?.type is 'ArrayExpression' and dependencyParams?.length
      usedDependencies = []
      for dependencyParam in dependencyParams
        return unless dependencyParam?.type is 'ObjectPattern'
        for property in dependencyParam.properties
          return unless property.type is 'Property'
          {key} = property
          return unless key.type is 'Identifier'
          usedDependencies.push key.name unless key.name in usedDependencies

      for dependency in dependencies.elements
        return unless dependency.type is 'Literal'
        {value} = dependency
        rootDependency = value.split('.')[0]
        unless rootDependency in usedDependencies
          reportUnused dependency

      rootDependencies = (dependency.value.split('.')[0] for dependency in dependencies.elements)
      for usedDependency in usedDependencies
        unless usedDependency in rootDependencies
          reportMissing node, usedDependency

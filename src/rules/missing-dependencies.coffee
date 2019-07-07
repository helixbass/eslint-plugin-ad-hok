{isArray, find} = require 'lodash'

{isFlow, isMagic, isBranchPure, getFlowToFlowMaxFixer} = require '../util'

dependencyGetters =
  addProps:
    getDependenciesArray: ({arguments: args}) ->
      args[1]
    getUsedProps: ({arguments: args}) ->
      objectPattern = args[0]?.params?[0]
      return null unless objectPattern?.type is 'ObjectPattern'
      usedProps = []
      for property in objectPattern.properties
        return null unless property.type is 'Property' and property.key.type is 'Identifier'
        usedProps.push property.key.name
      usedProps

getAddDependencyFixer = ({node, name, context}) ->
  sourceCode = context.getSourceCode()
  closingArrayBracket = sourceCode.getLastToken node

  (fixer) ->
    if node.elements.length is 0
      fixer.insertTextBefore closingArrayBracket, "'#{name}'"
    else
      fixer.insertTextBefore closingArrayBracket, ", '#{name}'"

module.exports =
  meta:
    docs:
      description: 'Flag dependency arrays that are missing dependencies'
      category: 'Possible Errors'
      recommended: yes
    schema: []
    fixable: 'code'

  create: (context) ->
    report = (node, name) ->
      context.report {
        node
        message: """Missing dependency: "#{name}\""""
        fix:
          getAddDependencyFixer {node, name, context}
      }

    CallExpression: (node) ->
      {callee} = node
      return unless callee.type is 'Identifier'
      getters = dependencyGetters[callee.name]
      return unless getters
      {getDependenciesArray, getUsedProps} = getters
      dependenciesArray = getDependenciesArray node
      return unless dependenciesArray?.type is 'ArrayExpression'
      for dependency in dependenciesArray.elements when dependency.type isnt 'Literal'
        return
      usedProps = getUsedProps node
      return unless isArray usedProps
      for usedProp in usedProps
        existingDependency = find dependenciesArray.elements, ({value}) -> value is usedProp
        continue if existingDependency
        report dependenciesArray, usedProp

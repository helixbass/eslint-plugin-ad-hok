{isFlowMax, isFlow, needsFlowMax} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag calls that are missing containing flowMax()'
      category: 'Possible Errors'
      recommended: yes
    schema: []

  create: (context) ->
    currentFlowOrFlowMaxCalls = []

    CallExpression: (node) ->
      if isFlowMax node
        currentFlowOrFlowMaxCalls.push {node, isFlowMax: yes}
        return
      if isFlow node
        currentFlowOrFlowMaxCalls.push {node, isFlowMax: no}
        return

      return unless needsFlowMax node
      return if currentFlowOrFlowMaxCalls.length and currentFlowOrFlowMaxCalls[currentFlowOrFlowMaxCalls.length - 1].isFlowMax
      context.report node, "#{node.callee.name}() only works with flowMax()"

    'CallExpression:exit': (node) ->
      return unless isFlowMax(node) or isFlow node
      currentFlowOrFlowMaxCalls.pop()

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

    isInFlowMax = ->
      currentFlowOrFlowMaxCalls.length and currentFlowOrFlowMaxCalls[currentFlowOrFlowMaxCalls.length - 1].isFlowMax

    Identifier: (node) ->
      return unless needsFlowMax node
      return if isInFlowMax()
      return unless currentFlowOrFlowMaxCalls.length
      context.report node, "#{node.name}() only works with flowMax()"

    CallExpression: (node) ->
      if isFlowMax node
        currentFlowOrFlowMaxCalls.push {node, isFlowMax: yes}
        return
      if isFlow node
        currentFlowOrFlowMaxCalls.push {node, isFlowMax: no}
        return

      return unless needsFlowMax node
      return if isInFlowMax()
      context.report node, "#{node.callee.name}() only works with flowMax()"

    'CallExpression:exit': (node) ->
      return unless isFlowMax(node) or isFlow node
      currentFlowOrFlowMaxCalls.pop()

{isFlowMax, needsFlowMax} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag unnecessary uses of flowMax()'
      category: 'General'
      recommended: yes
    schema: []

  create: (context) ->
    currentFlowMaxCalls = []

    setUsed = ->
      currentFlowMaxCalls[currentFlowMaxCalls.length - 1].used = yes

    Identifier: (node) ->
      return unless needsFlowMax node
      setUsed() if currentFlowMaxCalls.length

    CallExpression: (node) ->
      if isFlowMax node
        currentFlowMaxCalls.push {node}
        return

      return unless currentFlowMaxCalls.length
      return unless needsFlowMax node
      setUsed()

    'CallExpression:exit': (node) ->
      return unless isFlowMax node
      {used} = currentFlowMaxCalls.pop()
      return if used
      context.report node, "Unnecessary use of flowMax()"

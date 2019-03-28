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

    CallExpression: (node) ->
      if isFlowMax node
        currentFlowMaxCalls.push {node}
        return

      return unless currentFlowMaxCalls.length
      return unless needsFlowMax node
      currentFlowMaxCalls[currentFlowMaxCalls.length - 1].used = yes

    'CallExpression:exit': (node) ->
      return unless isFlowMax node
      {used} = currentFlowMaxCalls.pop()
      return if used
      context.report node, "Unnecessary use of flowMax()"

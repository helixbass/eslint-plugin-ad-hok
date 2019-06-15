isFlowMax = (node) ->
  node?.callee?.type is 'Identifier' and node.callee.name is 'flowMax'

isFlow = (node) ->
  node?.callee?.type is 'Identifier' and node.callee.name is 'flow'

magicHelperNames = [
  'returns'
  'renderNothing'
  'addPropTypes'
  'addWrapper'
  'addWrapperHOC'
  'branch'
]

isMagic = (node) ->
  return yes if isFlowMax node
  return unless node?.callee?.type is 'Identifier'
  node.callee.name in magicHelperNames

nonmagicHelperNames = [
  'addState'
  'addEffect'
  'addProps'
  'addHandlers'
  'addStateHandlers'
  'addRef'
  'addCallback'
  'addContext'
  'branchPure'
]

isFunction = (node) ->
  node?.type in ['FunctionExpression', 'ArrowFunctionExpression']

isBranchPure = (node) ->
  return unless node?.callee?.type is 'Identifier'
  node.callee.name is 'branchPure'

module.exports = {isFlowMax, isFlow, magicHelperNames, nonmagicHelperNames, isFunction, isMagic, isBranchPure}

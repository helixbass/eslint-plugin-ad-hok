isFlowMax = ({callee}) ->
  callee.type is 'Identifier' and callee.name is 'flowMax'

isFlow = ({callee}) ->
  callee.type is 'Identifier' and callee.name is 'flow'

magicHelperNames = [
  'returns'
  'renderNothing'
  'addPropTypes'
  'addWrapper'
  'addWrapperHOC'
  'branch'
]

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

needsFlowMax = ({callee, name}) ->
  if callee?
    return no unless callee.type is 'Identifier'
    return callee.name in ['returns', 'addPropTypes']
  name is 'renderNothing'

isFunction = (node) ->
  node?.type in ['FunctionExpression', 'ArrowFunctionExpression']

module.exports = {isFlowMax, isFlow, needsFlowMax, magicHelperNames, nonmagicHelperNames, isFunction}

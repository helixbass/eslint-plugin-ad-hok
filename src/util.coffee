path = require 'path'

isFlowMax = (node) ->
  node?.callee?.type is 'Identifier' and node.callee.name is 'flowMax'

isFlow = (node) ->
  node?.callee?.type is 'Identifier' and node.callee.name is 'flow'

isFlowOrFlowMax = (node) ->
  isFlowMax(node) or isFlow node

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
  'addPropsOnChange'
]

isNonmagicHelper = (node) ->
  return no unless node?.callee?.type is 'Identifier'
  node.callee.name in nonmagicHelperNames

isFunction = (node) ->
  node?.type in ['FunctionExpression', 'ArrowFunctionExpression']

isBranchPure = (node) ->
  return unless node?.callee?.type is 'Identifier'
  node.callee.name is 'branchPure'

getFlowToFlowMaxFixer = ({node, context}) ->
  (fixer) ->
    fixer.replaceText node.callee, 'flowMax'

getFlowMaxToFlowFixer = ({node, context}) ->
  (fixer) ->
    fixer.replaceText node.callee, 'flow'

getAddDisplayNameFixer = ({node, context}) ->
  (fixer) ->
    componentName = node.parent.id.name
    fixer.insertTextBefore node.arguments[0], "addDisplayName('#{componentName}'), "

shouldFix = ({context: {settings}}) ->
  !!settings['ad-hok/should-fix-flow-flowmax']

isTypescript = (context) ->
  extension = path.extname context.getFilename()
  extension in ['.ts', '.tsx']

module.exports = {isFlowMax, isFlow, magicHelperNames, nonmagicHelperNames, isFunction, isMagic, isNonmagicHelper, isBranchPure, getFlowToFlowMaxFixer, getFlowMaxToFlowFixer, shouldFix, getAddDisplayNameFixer, isTypescript, isFlowOrFlowMax}

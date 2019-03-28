isFlowMax = ({callee}) ->
  callee.type is 'Identifier' and callee.name is 'flowMax'

isFlow = ({callee}) ->
  callee.type is 'Identifier' and callee.name is 'flow'

needsFlowMax = ({callee}) ->
  return no unless callee.type is 'Identifier'
  callee.name in ['returns', 'renderNothing', 'addPropTypes']

module.exports = {isFlowMax, isFlow, needsFlowMax}

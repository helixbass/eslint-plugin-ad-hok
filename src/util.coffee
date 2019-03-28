isFlowMax = ({callee}) ->
  callee.type is 'Identifier' and callee.name is 'flowMax'

isFlow = ({callee}) ->
  callee.type is 'Identifier' and callee.name is 'flow'

needsFlowMax = ({callee, name}) ->
  if callee?
    return no unless callee.type is 'Identifier'
    return callee.name in ['returns', 'addPropTypes']
  name is 'renderNothing'

module.exports = {isFlowMax, isFlow, needsFlowMax}

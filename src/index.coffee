{flow, map: fmap, fromPairs: ffromPairs} = require 'lodash/fp'

ruleNames = ['no-unnecessary-flowmax', 'needs-flowmax', 'prefer-flowmax', 'no-flowmax-in-forwardref']

rules = do flow(
  -> ruleNames
  fmap (ruleName) -> [ruleName, require "./rules/#{ruleName}"]
  ffromPairs
)

module.exports = {rules}

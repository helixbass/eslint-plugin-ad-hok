{flow, map: fmap, fromPairs: ffromPairs} = require 'lodash/fp'

ruleNames = ['no-unnecessary-flowmax', 'needs-flowmax', 'prefer-flowmax']

rules = do flow(
  -> ruleNames
  fmap (ruleName) -> [ruleName, require "./rules/#{ruleName}"]
  ffromPairs
)

module.exports = {rules}

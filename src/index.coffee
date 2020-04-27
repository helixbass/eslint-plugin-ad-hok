{flow, map: fmap, fromPairs: ffromPairs} = require 'lodash/fp'

ruleNames = ['no-unnecessary-flowmax', 'needs-flowmax', 'prefer-flowmax', 'no-flowmax-in-forwardref', 'dependencies', 'require-adddisplayname']

rules = do flow(
  -> ruleNames
  fmap (ruleName) -> [ruleName, require "./rules/#{ruleName}"]
  ffromPairs
)

module.exports = {
  rules
  configs:
    recommended:
      plugins: ['ad-hok']
      parserOptions:
        ecmaFeatures:
          jsx: yes
      rules:
        'ad-hok/needs-flowmax': 'error'
        'ad-hok/prefer-flowmax': ['error', 'whenUsingUnknownHelpers']
        'ad-hok/no-flowmax-in-forwardref': 'error'
}

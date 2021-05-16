{flow, map: fmap, fromPairs: ffromPairs} = require 'lodash/fp'

ruleNames = [
  'no-unnecessary-flowmax'
  'needs-flowmax'
  'prefer-flowmax'
  'no-flowmax-in-forwardref'
  'dependencies'
  'require-adddisplayname'
  'annotate-handler-param-types'
  'cleanupprops-last'
  'getcontexthelpers-argument'
  'no-incompatible-branch-types'
]

rules = do flow(
  -> ruleNames
  fmap (ruleName) -> [ruleName, require "./rules/#{ruleName}"]
  ffromPairs
)

sharedRecommendRules =
  'ad-hok/no-flowmax-in-forwardref': 'error'
  'ad-hok/dependencies': ['error', {effects: no}]

module.exports = {
  rules
  configs:
    recommended:
      plugins: ['ad-hok']
      parserOptions:
        ecmaFeatures:
          jsx: yes
      rules: sharedRecommendRules
    'recommended-typescript':
      plugins: ['ad-hok']
      parserOptions:
        ecmaFeatures:
          jsx: yes
      rules: Object.assign {}, sharedRecommendRules,
        'ad-hok/annotate-handler-param-types': 'error'
        'ad-hok/cleanupprops-last': 'error'
        'ad-hok/getcontexthelpers-argument': 'error'
        'ad-hok/no-incompatible-branch-types': 'error'
}

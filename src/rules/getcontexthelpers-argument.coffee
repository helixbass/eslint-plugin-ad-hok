{isString} = require 'lodash'

{isTypescript, shouldFix} = require '../util'

module.exports =
  meta:
    docs:
      description: 'Flag invalid calls to getContextHelpers()'
      category: 'Possible Errors'
      recommended: yes
    schema: []
    fixable: 'code'

  create: (context) ->
    return {} unless isTypescript context

    CallExpression: (node) ->
      {callee, typeParameters, arguments: args} = node
      return unless (
        callee?.type is 'Identifier' and callee.name is 'getContextHelpers'
      )

      return unless typeParameters
      {params} = typeParameters
      return unless params?.length
      [param] = params
      return unless param.type is 'TSTypeLiteral'
      typeKeys = []
      for property in param.members
        return unless property.type is 'TSPropertySignature'
        return unless property.key?.type is 'Identifier'
        typeKeys.push property.key.name

      if args.length is 0
        return unless shouldFix {context}
        context.report {
          node
          message: '''
            getContextHelpers() expects a single argument
          '''
          fix: (fixer) ->
            sourceCode = context.getSourceCode()
            lastToken = sourceCode.getLastToken node
            return unless lastToken.value is ')'
            fixer.insertTextBefore(
              lastToken
              "toObjectKeys([#{("'#{key}'" for key in typeKeys).join ', '}])"
            )
        }
        return

      [arg] = args
      return unless arg.type is 'CallExpression'
      {callee: toObjectKeysCallee, arguments: toObjectKeysArgs} = arg
      return unless (
        toObjectKeysCallee.type is 'Identifier' and
        toObjectKeysCallee.name is 'toObjectKeys'
      )
      return unless toObjectKeysArgs.length
      [toObjectKeysArg] = toObjectKeysArgs
      return unless toObjectKeysArg.type is 'ArrayExpression'
      arrayKeys = []
      for arrayElement, index in toObjectKeysArg.elements
        return unless (
          arrayElement?.type is 'Literal' and isString arrayElement.value
        )
        arrayKeys.push {
          node: arrayElement
          index
        }

      for typeKey in typeKeys
        continue if arrayKeys.find ({node: {value}}) -> value is typeKey
        context.report {
          node
          message: """
            Key "#{typeKey}" is present in the context type but not the toObjectKeys() argument
          """
          fix: (fixer) ->
            sourceCode = context.getSourceCode()
            lastToken = sourceCode.getLastToken toObjectKeysArg
            return unless lastToken.value is ']'
            fixer.insertTextBefore(
              lastToken
              "#{if arrayKeys.length then ', ' else ''}'#{typeKey}'"
            )
        }

      numArrayKeys = toObjectKeysArg.elements.length
      for arrayKey in arrayKeys
        # eslint-disable-next-line coffee/no-shadow
        continue if typeKeys.find (typeKey) -> typeKey is arrayKey.node.value
        context.report
          node: arrayKey.node
          message: """
            Key "#{arrayKey.node.value}" is not present in the context type
          """
          fix: (fixer) ->
            if arrayKey.index is numArrayKeys - 1
              fixer.remove arrayKey.node
            else
              fixer.removeRange [
                arrayKey.node.range[0]
                toObjectKeysArg.elements[arrayKey.index + 1].range[0]
              ]

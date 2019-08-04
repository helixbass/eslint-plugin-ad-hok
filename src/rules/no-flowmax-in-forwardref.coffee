module.exports =
  meta:
    docs:
      description: 'Flag uses of flowMax() within forwardRef()'
      category: 'Possible Errors'
      recommended: yes
    schema: [
      type: 'object'
      additionalProperties: no
    ]
    fixable: 'code'

  create: (context) ->
    report = (node) ->
      context.report {
        node,
        message: "flowMax() cannot be used within forwardRef()"
      }

    "CallExpression[callee.name='forwardRef'] CallExpression[callee.name='flowMax']":
      (node) -> report node
    "CallExpression[callee.object.name='React'][callee.property.name='forwardRef'] CallExpression[callee.name='flowMax']":
      (node) -> report node

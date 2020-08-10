# ad-hok/no-mutable-singleton-initial-values

This rule flags potentially mutable shared "global" initial values for
[`addState()`](https://github.com/helixbass/ad-hok#addstate)/[`addStateHandlers()`](https://github.com/helixbass/ad-hok#addstatehandlers)

### Motivation

`addState()` and `addStateHandlers()` accept their initial values either "raw" or as a function of props. When using the "raw" form, only
one instance of those initial values 

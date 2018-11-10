#export default
exports = {}

### @param test - paramenter expression for directive
###
showHide = (showing) -> (test, display) -> (comp) ->
  comp.showHide(showing, test, display)
  comp

exports.$show = showHide(true)

exports.$hide = showHide(false)

export default module.exports = exports
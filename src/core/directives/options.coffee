#{Value} = require 'bind-expression'
{Tag, List} = require '../base'
{repeat, txt} = require '../instantiate'
{option} = require '../tag'

# options directive， used for select tag
module.exports = (exp, attrs) -> (comp) ->
  if comp not instanceof Tag or comp.tagName!='select'
    throw new Error 'options should be only used in select tag'
  comp.children = new List([repeat(exp, (item) -> option(attrs, [txt(item)]))])
  comp
{list, repeat
text, p
bindings} =require 'domcom/src/index'

exports.demoRepeat1 = ->
  lst = [1, 2]
  comp = list(lst)
  comp.mount()

exports.demoRepeat2 = ->
  lst = [1, 2]
  comp = repeat(lst, (item) -> p item)
  comp.mount()

exports.demoRepeat3 = ->
  lst = [1, 2, 3, 4, 5, 6]
  comp = repeat(lst, (item) -> p item)
  comp.mount()
  setTimeout((-> lst.push 7; comp.update()), 2000)
  setTimeout((-> lst.length = 4; comp.update()), 4000)

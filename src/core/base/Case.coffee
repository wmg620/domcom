toComponent = require './toComponent'
TransformComponent = require './TransformComponent'
{funcString, newLine} = require '../../util'

module.exports = class Case extends TransformComponent
  constructor: (test, map, else_, options) ->
    super(options)
    for key, value of map
      map[key] = toComponent(value) #.inside(@, @)
    else_ = toComponent(else_) #.inside(@, @)
    if typeof test == 'function'
      @getVirtualTree = =>
        content = (map[test()] or else_)
        vtree = content.getVirtualTree()
        vtree.vtreeRootComponent = @
        vtree.srcComponents.unshift([@, null])
        @vtree = vtree
      @setParentNode = (node) ->
        @parentNode = node
        for _, value of map then map[key].setParentNode.node
        else_.setParentNode node
    else
      content = (map[test] or else_)
      vtree = content.getVirtualTree()
      vtree.srcComponents.unshift([@, null])
      @getVirtualTree = -> vtree
      @setParentNode = (node) ->
        @parentNode = node
        content.setParentNode node

    @clone = (options) ->
      cloneMap = Object.create(null)
      for key, value of map
        cloneMap[key] = value.clone()
      (new Case(test, cloneMap, else_clone(), options or @options)).copyLifeCallback(@)

    @toString = (indent=0, noNewLine) ->
      s = newLine(indent, noNewLine)+'<Case '+funcString(test)+'>'
      for key, comp of map
        s += newLine(key+': '+comp.toString(indent+2, true), indent+2)
      s += else_.toString(indent+2)+newLine('</Case>', indent)

    this

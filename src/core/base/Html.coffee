Tag = require './Tag'
{funcString, newLine} = require 'dc-util'
{domValue, domField} = require '../../dom-util'

# !!! Warning:
# By default, Html does not escape to safe the html.
# So it's UNSAFE to use Html class without a transform function!!!
# It's the responsibilityn of user program to keep it in safe!
# Maybe a npm package like escape-html will help.

# this is Html Component, which take some text as innerHTML
# for <html> ... </html>, please use tagHtml instead

module.exports = class Html extends Tag
  constructor: (attrs, text, transform) ->
    if typeof attrs == 'string' || typeof attrs == 'function'
      @transform = text
      text = attrs
      attrs = {}
    else
      attrs = attrs || {}
      @transform = transform

    @_text = text = domField(text)

    me = @
    if typeof text == 'function'
      text.onInvalidate ->
        me.textValid = false
        me.invalidate()

    super('div', attrs, [])

    if Object.defineProperty

      get: -> me._text

      set = (text) ->
        me.setText(text)
        text

      Object.defineProperty(this, 'text', {set})

    this

  createDom: ->
    @textValid = true
    @node = @firstNode = node = document.createElement('div')
    node.component = this
    this.updateProperties()
    this.cacheText = node.innerHTML = @transform and @transform(domValue(@_text)) or domValue(@_text)
    @

  updateDom: ->
    if @textValid
      return @

    @textValid = true
    text = @transform and @transform(domValue(@_text)) or domValue(@_text)

    node = @node

    if text!=@cacheText
      if node.childNodes.length >=2
        if node.parentNode
          @removeNode()
        @node = @firstNode = node = node.cloneNode(false)
        node.component = this
      node.innerHTML =  text

      @cacheText = text
    # else null # text do not change, do nothing

    # this should be done after this.node is processed
    # because may be cloneNode
    this.updateProperties()

    @

  setText: (text) ->
    text = domField(text)
    if @_text == text
      return this

    @textValid = false
    @_text = text

    me = @
    if typeof text == 'function'
      text.onInvalidate ->
        me.textValid = false
        me.invalidate()
    @invalidate()
    @

  toString: (indent=2, addNewLine) ->
    newLine("<Html #{funcString(@_text)}/>", indent, addNewLine)

ListMixin = require('./ListMixin')
for method of ListMixin
  Html.prototype[method] = ->
    dc.error('Html component has no children components, do not call ListMixin method on it')

# initChildren is called by the constructor of Tag class
# so put a empty definition here
Html.prototype.initChildren = ->

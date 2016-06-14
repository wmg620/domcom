extend = require('extend')

{normalizeDomElement} = require('../../dom-util')
{newDcid, isArray} = require('dc-util')
{flow} = require('lazy-flow')
isComponent = require('./isComponent')
dc = require('../../dc')

module.exports = class Component
  constructor: ->
    # maybe this.listeners is be set in sub class's component.on(...) call in advance
    # if that, keep it
    this.listeners = this.listeners || {}
    this.baseComponent = null
    this.parentNode = null
    this.nextNode = null
    this.node = null
    this.destroyed = false
    this.holder = null
    this.dcid = newDcid()
    this.valid = true
    this.attachValid = true
    this.setReactive()

  _prepareMount: (mountNode, beforeNode) ->
    if mountNode && mountNode.component
      mountNode = mountNode.component
    else if beforeNode && beforeNode.component
      console.log(mountNode)
      console.log(beforeNode)
      throw new Error('error while mounting: mountNode is not a component, but beforeNode is a component')

    if isComponent(mountNode)
      if !beforeNode
        if !mountNode.children
          console.log(mountNode)
          throw new Error('error while mounting: mountNode is a component, but is not a Tag or List component')
        mountNode.pushChild(this)
      else
        if !isComponent(beforeNode)
          beforeNode = beforeNode.component
          if !beforeNode
            console.log(beforeNode)
            throw new Error('error while mounting: can not mount beforeNode')
        if beforeNode.holder != mountNode || !mountNode.children
          console.log(mountNode)
          console.log(beforeNode)
          throw new Error('both mountNode and beforeNode is component, but mountNode is not the parent of beforeNode')
        mountNode.insertChildBefore(this, beforeNode)
    else
      this.parentNode = normalizeDomElement(mountNode) || this.parentNode || document.body
      this.nextNode = beforeNode || this.nextNode
      this.setHolder(dc)
      dc.rootComponentMap[this.dcid] = this

  create: (mountNode, beforeNode, forceRender) ->
    this._prepareMount(mountNode, beforeNode)
    this.render(forceRender)

  ### if mountNode is given, it should not be the node of any Component
  only use beforeNode if mountNode is given
  ###
  mount: (mountNode, beforeNode, forceRender) ->
    this.emit('willMount')
    this._prepareMount(mountNode, beforeNode)
    this.render(forceRender)
    this.emit('didMount')

  unmount: (forceRender) ->
    this.emit('willUnmount')
    this.remove()
    this.emit('didUnmount')

  remove: ->
    holder = this.holder
    if !holder || holder == dc
      delete dc.rootComponentMap[this.dcid]
      firstNode = this.firstNode
      if firstNode && firstNode.parentNode
        if (prevNode = firstNode.previousSibling) && prevComponent = prevNode.component
          prevComponent.setNextNode(this.nextNode)
        this.removeNode()
    else if holder.children
      holder.removeChild(this)
    else if holder
      dc.error('Should not remove the content of TransformComponent')
    this

  memoRemoving: (component) ->
    holder = this.holder
    if !holder || holder == dc
      this.removingChildren[component.dcid] = component
    else if this.isTag || this.isRenderHolder
      this.removingChildren[component.dcid] = component
    else
      this.holder.memoRemoving(component)
    return

  # normally only Tag and List will have removingChildren
  # but the removing component of TransformComponent will be added to TransformComponent.baseComponent
  removeChildrenDom: ->
    for _, child of this.removingChildren
      child.removeDom()
    this.removingChildren = {}
    return

  asRenderHolder: (isRenderHolder = true) ->
    this.isRenderHolder = isRenderHolder
    this

  render: (forceRender) ->
    if !this.destroyed && (forceRender || dc.alwaysRender || !dc.renderBySystemLoop)
      if this.removing
        this.removeDom()
      else
        this.refreshDom(this.baseComponent)
    this

  renderHolder: (forceRender) ->
    if this.holder
      this.holder.render(forceRender)
    else
      this.render(forceRender)

  replace: (oldComponent, forceRender) ->
    if this.destroyed || this == oldComponent
      return
    holder = oldComponent.holder
    if holder && holder != dc
      if holder.isTransformComponent
        dc.error('Should not replace the content of TransformComponent')
      else
        # holder is List or Tag
        holder.replaceChild(oldComponent, this)
        holder.render(forceRender)
    else if holder == dc
      this.parentNode = oldComponent.parentNode
      this.nextNode = oldComponent.nextNode
      oldComponent.markRemovingDom(this)
      this.setHolder(holder)
      this.invalidate()
      dc.rootComponentMap[this.dcid] = this
      dc.rootComponentMap[oldComponent.dcid] = oldComponent
      this.render(forceRender)
    this

  ###
  component.renderWhen components, events
  component.renderWhen setInterval, interval, options
  component.renderWhen setTimeout, interval, options
  ###
  renderWhen: (component, events, options) ->
    if isArray(component) || isComponent(component)
      options = [this]
    else
      options = options || {}
      options.components = [this]
    dc.renderWhen(component, events, options)
    this

  destroy: ->
    this.unmount(true)
    this.destroyed = true
    this.listeners = null
    if this.node
      this.node.component = null
      this.node = null
    this.baseComponent = null
    this.parentNode = null

  getPrevComponent: ->
    if !(holder = this.holder)
      null
    else if children = holder.children
      chilren[children.indexOf(this)]

  getNextComponent: ->
    if !(holder = this.holder)
      null
    else if children = holder.holder.children
      children[children.indexOf(this)]

  setNextNode: (nextNode) ->
    this.nextNode = nextNode
    return

  setHolder: (holder) ->
    if this.holder && this.holder != holder
      this.holder.invalidateAttach(this)
    this.holder = holder
    this

  isOffspringOf: (ancestor) ->
    holder = this.holder
    while holder
      if holder == ancestor
        return true
      holder = holder.holder
    false

  inFamilyOf: (ancestor) ->
    this == ancestor || this.isOffspringOf(ancestor)

  setReactive: ->
    if this.reactMap
      me = this
      invalidateThis = -> me.invalidate()
      for srcField, reactField of this.reactMap
        reactive = flow.bind(this, srcField)
        if typeof reactField == 'string'
          reactive.onInvalidate ->
            if reaction = me[reactField]
              reaction.invalidate()
        else
          reactive.onInvalidate invalidateThis
    this

  copyEventListeners: (srcComponent) ->
    myListeners = this.listeners
    srcListeners = srcComponent.listeners
    for event of srcListeners
      srcListeners[event] && myListeners[event] = srcListeners[event].splice()
    this

dcEventMixin = require('../../dc-event')
extend(Component.prototype, dcEventMixin)
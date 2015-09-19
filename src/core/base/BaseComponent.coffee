Component = require './component'
{insertNode, removeNode} = require '../../dom-util'
{cloneObject} = require '../../util'

module.exports = class BaseComponent extends Component
  constructor: (options) ->
    super(options)
    @activeOffspring = null
    @isBaseComponent = true
    @baseComponent = @

  getBaseComponent: ->
    @mountCallbackComponentList = if @mountCallbackList then [@] else []
    @unmountCallbackComponentList = if @unmountCallbackList then [@] else []
    @

  attachNode: (nextNode) ->
    @unmounted = false
    @parentNode and @parentNode.insertBefore(@node, nextNode)

  # this method will be called after updateProperties and before updating chidlren or activeOffspring
  resetContainerHookUpdater: ->
    @noop = !@hasActiveProperties and !@mountCallbackComponentList.length # will always be set again while offspring is changed
    if !@holder or @holder.isTransformComponent
      @isContainer = true
      # do not need to hook updater, just to be itself
    else if !@noop or @isUpdateRoot
      @isContainer = true
      holder = @holder
      # the condition for isContainer ensure reaching baseComponent before transformCompnent or null
      while !holder.isContainer then holder = holder.holder
      @hookUpdater = holder
      holder.activeOffspring = holder.activeOffspring or Object.create(null)
      holder.activeOffspring[dcid] = @
      holder.noop = false # offspring update holder.noop!!!

  updateOffspring: () ->
    {activeOffspring} = @
    if !activeOffspring then return
    @activeOffspring = null
    for dcid, component of activeOffspring
      component.render()
    return

  invalidate: ->
    if !@noop then return
    @noop = false
    holder = @holder
    while holder and !holder.isContainer
      holder = holder.holder
    if !holder then return
    holder.activeOffspring = holder.activeOffspring or Object.create(null)
    holder.activeOffspring[@dcid] = @
    holder.invalidate()

  replace: (baseComponent, rootContainer) ->
    @removeNode()
    @executeUnmountCallback()
    prevNodeComponent = @prevNodeComponent
    nextNodeComponent = @nextNodeComponent
    firstNodeComponent = baseComponent.firstNodeComponent
    if firstNodeComponent
      holder = baseComponent.holder
      if prevNodeComponent then prevNodeComponent.nextNodeComponent = firstNodeComponent
      else holder and holder.firstNodeComponent = firstNodeComponent
      if nextNodeComponent then nextNodeComponent.prevNodeComponent = baseComponent.lastNodeComponent
      else holder and holder.lastNodeComponent = baseComponent.lastNodeComponent
    if !baseComponent.node then baseComponent.createDom()
    else if !baseComponent.noop then baseComponent.updateDom(true) # mounting = true
    baseComponent.attachNode(@nextNodeComponent and @nextNodeComponent.node or rootContainer.mountBeforeNode)
    return

  remove: ->
    @removeNode()
    @executeUnmountCallback()
    prevNodeComponent = @prevNodeComponent
    nextNodeComponent = @nextNodeComponent
    prevNodeComponent and prevNodeComponent.nextNodeComponent = nextNodeComponent
    nextNodeComponent and nextNodeComponent.prevNodeComponent = prevNodeComponent
    return

  removeNode: ->
    if !@parentNode or @unmounted then return
    @parentNode.removeChild(@node)
    @unmounted = true

  executeMountCallback: ->
    for component in @mountCallbackComponentList
      for cb in component.mountCallbackList then cb()
    return

  executeUnmountCallback: ->
    for component in @unmountCallbackComponentList
      for cb in component.unmountCallbackList then cb()
    return

  getNode: -> @node

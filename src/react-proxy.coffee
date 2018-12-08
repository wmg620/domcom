{normalizeItem} = require 'dc-util'

###
addReactProxy should be attached to dc and called like below:
  dc.addReactProxy(React, ReactDom, ReactComponent)
###
export default module.exports = addReactProxy = (React, ReactDom, ReactComponent) ->
  dc = this
  dc.React = React
  dc.ReactDom = ReactDom

  dc.ReactProxy = class ReactProxy extends ReactComponent
    constructor: (props) ->
      super(props)
      {component} = props
      this.component = component
      component.proxy = this
      return

    componentWillMount: ->
      if this.component.mounted
        dc.error 'component should be mounted under only one place'
      this.component.emit 'mounting'
      this.component.mounted = true
      return

    componentDidMount: ->
      this.component.node = ReactDom.findDOMNode(this)
      this.component.emit 'mounted'

      return

    componentWillUnmount: ->
      this.component.emit 'unmounting'
      this.component.mounted = false
      this.component.node = null
      return

    componentDidCatch: (error) ->
      dc.error(error)

    renderNormalized: (item) =>
      if !item?
        return null
      else if typeof item == 'string'
        return item
      else if dc.React.isValidElement(item)
        return item
      else
        if directives = item[1]['#']
          delete item[1]['#']
          for directive in directives
            func = directive[0]
            item = func.call(this.component, item, directive[1...]...)
        [tag, props, children] = item
        children = children.map (child) => this.renderNormalized(child)
        if !children.length
          children = null
        else if children.length == 1
          if props.useSingleChildren
            children = children[0]
        return React.createElement(tag, props, children)

    renderItem: (item) =>
      item = normalizeItem(item)
      debugger
      return this.renderNormalized(item)

    render: ->
      {component} = this
      try
        view = component.getView()
        reactElement = this.renderItem(view)
      catch err
        dc.error "catched error in ReactProxy.render:#{err}"
      return reactElement

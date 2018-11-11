{expect, iit, idescribe, nit, ndescribe} = require 'bdd-test-helper'

{newDemoNode} = require './helper'

{
Tag, Text, List, txt, list
p, div, Html, html, if_
classFn, styleFrom,
Nothing
isComponent
getters
mvc
} = dc

describe "test vue back end", ->
  afterEach ->
    dc.reset()

  describe 'update BaseBlock', ->

    it 'should mount simple vue div block', ->
      dr = dc.vue()
      expect(dr).to.be.instanceof(dc.Vue)
      {div} = dr
      comp = div({}, ['hello'])
      expect(comp).to.be.instanceof(dc.VueBlock)
      comp.mount('#demo2')

    it 'should mount embedded vue div block', ->
      dr = dc.vue()
      {div} = dr
      comp = div({}, div({key:1}, 'hello'))
      expect(comp).to.be.instanceof(dc.VueBlock)
      comp.mount('#demo2')
      comp.update()

    it 'should mount vue mvc + div block', ->
      dv = dc.vue()
      {div} = dv
      view = () -> if_(this.showing, div(this.message))
      comp = mvc(view)
      comp.showing = true
      comp.message = 'hello mvc'
      comp.mount('#demo2')
      comp.message = 'hello mvc 2'
      comp.showing = false
      2
      comp.update()

    it 'should mount and update vue mvc + if_ div block', ->
      dr = dc.react()
      {div} = dr
      expect(dr).to.be.instanceof(dc.React)
      view = () -> if_(this.showing, div(this.message1), div(this.message2))
      comp = mvc(view)
      comp.showing = true
      comp.message1 = 'hello mvc 1'
      comp.message2 = 'hello mvc 2'
      comp.mount('#demo2')
      comp.showing = false
      comp.update()

    iit 'should mount and update vue mvc + if_ div block 2', ->
      dr = dc.react()
      {div} = dr
      expect(dr).to.be.instanceof(dc.React)
      view = () -> if_(this.showing, div(this.message1))
      comp = mvc(view)
      comp.showing = true
      comp.message1 = 'hello mvc 1'
      comp.mount('#demo2')
      comp.showing = false
      comp.update()
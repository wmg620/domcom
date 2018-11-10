import route from './route'

module.exports = exports =
  isComponent: require('./isComponent')
  toComponent: require('./toComponent')
  toComponentArray: require('./toComponentArray')
  Component: require('./Component')
  BaseComponent: require('./BaseComponent')
  ListMixin: require('./ListMixin')
  List: require('./List')
  Tag: require('./Tag')
  Text: require('./Text')
  Comment: require('./Comment')
  Cdata: require('./Cdata')
  Html: require('./Html')
  Nothing: require('./Nothing')
  TranComponent: require('./TranComponent')
  TestComponent: require('./TestComponent')
  If: require('./If')
  MVC: require('./MVC')
  Case: require('./Case')
  Func: require('./Func')
  Pick: require('./Pick')
  Defer: require('./Defer')
  Route: route.Route
  route: route

export default exports
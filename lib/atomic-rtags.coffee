config = require './config'
menu = require './menu'

configObserver = null

reset = ->
  Promise.resolve()

activate = ->
  configObserver = atom.config.observe 'atomic-rtags', reset
  menu.register()

deactivate = ->
  configObserver?.dispose()
  menu.deregister()
  reset()

module.exports =
  config: config
  activate: activate
  deactivate: deactivate

{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-blink1:index')
Blink1Manager          = require './blink1-manager'

class Connector extends EventEmitter
  constructor: ->
    @blink1 = new Blink1Manager

  changeColor: ({color}, callback) =>
    @blink1.updateColor {color}, callback

  close: (callback) =>
    debug 'on close'
    callback()

  isOnline: (callback) =>
    callback null, running: true

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  turnOff: (callback) =>
    @blink1.turnOff callback

module.exports = Connector

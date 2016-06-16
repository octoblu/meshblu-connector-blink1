{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-blink1:index')
Blink1Client          = require './blink1-client'

class Connector extends EventEmitter
  constructor: ->
    @blink1 = new Blink1Client

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

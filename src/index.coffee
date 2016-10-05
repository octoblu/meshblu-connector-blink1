{EventEmitter} = require 'events'
_              = require 'lodash'
debug          = require('debug')('meshblu-connector-blink1:index')
Blink1Manager  = require './blink1-manager'

class Connector extends EventEmitter
  constructor: ->
    @blink1 = new Blink1Manager
    @blink1.on 'update', (data) =>
      console.log 'update', JSON.stringify data
      @emit 'update', data

  changeColor: ({color}, callback) =>
    @blink1.updateColor {color}, callback

  close: (callback) =>
    debug 'on close'
    callback()

  isOnline: (callback) =>
    callback null, running: true

  onConfig: (device={}, callback=->) =>
    color = _.get device, 'desiredState.color'
    debug 'on config', {color}

    return unless color?
    @blink1.updateColor {color}, callback

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  turnOff: (callback) =>
    @blink1.turnOff callback

module.exports = Connector

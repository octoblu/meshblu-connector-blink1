{EventEmitter}  = require 'events'
Blink1Client    = require './blink1-client'
tinycolor       = require 'tinycolor2'
debug           = require('debug')('meshblu-connector-blink1:index')

class Blink1 extends EventEmitter
  constructor: ->
    @client = new Blink1Client

  isOnline: (callback) =>
    callback null, running: true

  parseColor: (payload={}) =>
    return tinycolor 'black' unless payload.on
    return tinycolor 'white' unless payload.color?
    return tinycolor payload.color

  onMessage: (message) =>
    { payload, devices } = message
    return if '*' in devices
    debug 'on message'
    @client.updateColor @parseColor payload

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid

module.exports = Blink1

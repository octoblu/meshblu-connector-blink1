{EventEmitter} = require 'events'
_              = require 'lodash'
request        = require 'request'
tinycolor      = require 'tinycolor2'
debug          = require('debug')('meshblu-connector-blink1:blink1')

try
  unless process.env.SKIP_REQUIRE_BLINK1 == 'true'
    Blink1 = require 'node-blink1'
catch error
  console.error error

class Blink1Manager extends EventEmitter
  constructor: ->
    @_emit = _.throttle @emit, 500, {leading: true, trailing: false}
    # hooks for test
    @Blink1 = Blink1
    @request = request

  getLight: (callback) =>
    getLightFunc = @getLightViaHttp
    getLightFunc = @getLightViaUSB if @Blink1?
    getLightFunc callback

  getLightViaHttp: (callback) =>
    @request.get 'http://127.0.0.1:8934/blink1/lastColor', json: true, (error, {statusCode}={}, body) =>
      return callback error if error?
      return callback new Error("Expected HTTP 200, received HTTP #{statusCode}") unless statusCode == 200
      return callback null, {
        color: tinycolor(body.lastColor).toHex8String()
      }

  getLightViaUSB: (callback) =>
    try
      blink1 = new @Blink1
      blink1.rgb (r, g, b) =>
        callback null, {
          color: tinycolor({r, g, b}).toHex8String()
        }
        blink1.close()
    catch error
      console.error 'Possible conflict with the blink1Control app, close it for better results'
      console.error error
      console.error 'trying over http'
      @getLightViaHttp (httpError, light) =>
        # if http also failed, send the original USB error message
        return callback error if httpError?
        callback null, light

  turnOff: (callback) =>
    @updateColor color: 'black', callback

  updateColor: ({color}, callback) =>
    color = tinycolor color
    updateColorFunc = @updateColorViaHttp
    updateColorFunc = @updateColorViaUSB if @Blink1?

    updateColorFunc {color}, (error) =>
      return callback error if error?
      @_updateState desiredState: null, callback

  updateColorViaUSB: ({color}, callback) =>
    debug 'updating color via usb'
    rgb = color.toRgb()
    rgb.r = rgb.a * rgb.r
    rgb.g = rgb.a * rgb.g
    rgb.b = rgb.a * rgb.b
    try
      blink1 = new @Blink1
      blink1.fadeToRGB 0, rgb.r, rgb.g, rgb.b
      blink1.close()
      debug 'color changed! (USB)'
      callback()
    catch error
      console.error 'Possible conflict with the blink1Control app, close it for better results'
      console.error error
      console.error 'trying over http'
      @updateColorViaHttp {color}, (httpError) =>
        # if http also failed, send the original USB error message
        return callback error if httpError?
        callback null

  updateColorViaHttp: ({color}, callback) =>
    debug 'updating color over http'
    rgb = color.toHexString()
    uri = 'http://127.0.0.1:8934/blink1/fadeToRGB'
    @request.get uri, { qs: { rgb } }, (error, response) =>
      if error?
        console.error error.message
        callback error
        return

      return callback new Error 'Update Color via HTTP failed!' if response.statusCode >= 499

      debug 'color changed! (HTTP)'
      callback()

  _updateState: (update={}, callback=_.noop) =>
    @getLight (error, light) =>
      return callback error  if error?
      return callback new Error 'Could not find blink(1)' unless light?
      deviceUpdate = {options: {color: light.color}}
      update = _.assign {}, update, deviceUpdate
      @_emit 'update', update
      callback()

module.exports = Blink1Manager

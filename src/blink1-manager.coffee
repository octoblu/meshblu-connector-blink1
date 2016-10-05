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
    blink1 = new @Blink1
    blink1.rgb (r, g, b) =>
      callback null, {
        color: tinycolor({r, g, b})
      }

  turnOff: (callback) =>
    @updateColor color: 'black', callback

  updateColor: ({color}, callback) =>
    color = tinycolor color
    updateFunc = @updateColorViaHttp
    updateFunc = @updateColorViaUSB if @Blink1?

    updateFunc {color}, (error) =>
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
        callback httpError

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
      return callback() if error?
      deviceUpdate = _.pick light, ['color']
      update = _.merge update, deviceUpdate
      @_emit 'update', update
      callback()

module.exports = Blink1Manager

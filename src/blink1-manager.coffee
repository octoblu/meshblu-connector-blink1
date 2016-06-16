request   = require 'request'
tinycolor = require 'tinycolor2'
debug     = require('debug')('meshblu-connector-blink1:blink1')
try
  Blink1 = require 'node-blink1'
catch error
  console.error error

class Blink1Manager
  constructor: ->
    # hooks for test
    @Blink1 = Blink1
    @request = request

  turnOff: (callback) =>
    @updateColor color: 'black', callback

  updateColor: ({color}, callback) =>
    color = tinycolor color
    return @updateColorViaUSB {color}, callback if @Blink1?
    @updateColorViaHttp {color}, callback

  updateColorViaUSB: ({color}, callback) =>
    debug 'updating color via usb'
    rgb = color.toRgb();
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
    @request.get uri, { qs: { rgb } }, (error, response, body) =>
      if error?
        console.error error.message
        callback error
        return

      return callback new Error 'Update Color via HTTP failed!' if response.statusCode >= 499

      debug 'color changed! (HTTP)'
      callback()

module.exports = Blink1Manager

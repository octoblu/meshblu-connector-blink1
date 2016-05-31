request = require 'request'
debug   = require('debug')('meshblu-connector-blink1:blink1')

class Blink1Client
  constructor: ->

  getBlink1: =>
    try
      return require 'node-blink1'
    catch error
      console.error error
    return null

  updateColor: (color) =>
    Blink1 = @getBlink1()
    return @updateColorViaUSB color, Blink1 if Blink1?
    return @updateColorViaHttp color unless Blink1?

  updateColorViaUSB: (color, Blink1) =>
    debug 'updating color via usb'
    rgb = color.toRgb();
    rgb.r = rgb.a * rgb.r
    rgb.g = rgb.a * rgb.g
    rgb.b = rgb.a * rgb.b
    try
      blink1 = new Blink1
      blink1.fadeToRGB 0, rgb.r, rgb.g, rgb.b
      blink1.close()
    catch error
      console.error 'Possible conflict with the blink1Control app, close it for better results'
      console.error error
      console.error 'trying over http'
      @updateColorViaHttp color
      return

    debug 'color changed! (USB)'

  updateColorViaHttp: (color) =>
    debug 'updating color over http'
    rgb = color.toHexString()
    uri = 'http://127.0.0.1:8934/blink1/fadeToRGB'
    request.get uri, { qs: { rgb } }, (error, response, body) =>
      return console.error error.message if error?
      debug 'color changed! (HTTP)'

module.exports = Blink1Client

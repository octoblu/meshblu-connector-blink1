http = require 'http'

class Off
  constructor: ({@connector}) ->
    throw new Error 'Off requires connector' unless @connector?

  do: (message, callback) =>
    @connector.turnOff callback

module.exports = Off

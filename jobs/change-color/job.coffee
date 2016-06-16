http = require 'http'

class ChangeColor
  constructor: ({@connector}) ->
    throw new Error 'ChangeColor requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.color is required') unless data?.color?
    {color} = data
    @connector.changeColor {color}, callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = ChangeColor

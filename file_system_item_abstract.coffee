fs = require 'fs'

class FileSystemItemAbstract

  watch: true

  get_extension: (str) ->
    str.substring( (str.lastIndexOf('.') + 1) || str.length )

  trim_ext: (str) ->
    return str unless ~str.lastIndexOf('.')
    str.substring( 0, str.lastIndexOf('.') )

  constructor: (@options) ->

    console.log @options.path if @options.debug

    {

      @path
      @destination

      @recursive
      @relativePath

      @watched_list
      @on_change
      @freshen
      @repeat_callback

      @as_object
      @filenamesOnly

    } = @options


  # Some options should not be passed down
  extractSingleUseOptions: ->
    _.each [
      'top'
      'white_list'
      'black_list'
    ], (key) =>
      @[key] = @options[key]
      delete @options[key]

  restart: ->
    fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()
    require './loaddir_tmp_restart'
    fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()

module.exports = FileSystemItemAbstract

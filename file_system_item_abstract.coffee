fs = require 'fs'
_ = require 'underscore'

class FileSystemItemAbstract extends Object

  get_extension: (str) ->
    str.substring( (str.lastIndexOf('.') + 1) || str.length )

  trim_ext: (str) ->
    return str unless ~str.lastIndexOf('.')
    str.substring( 0, str.lastIndexOf('.') )

  constructor: (@options) ->

    @options.to_filename ?= @to_filename

    {
      @as_object
      @binary
      @black_list
      @callback
      @compile
      @baseName
      @destination
      @extension
      @fast_watch
      @fileName
      @on_change
      @path
      @recursive
      @relativePath
      @repeat_callback
      @require
      @to_filename
      @watch
      @watch_handler
      @watched_list
      @file_watchers
      @output
    } = @options
    super

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

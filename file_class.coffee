FileSystemItemAbstract = require './file_system_item_abstract_class'
Directory = require './directory_class'
fs = require 'fs'

IMAGE_FORMATS = [
  'png'
  'gif'
  'jpg'
  'jpeg'
]

class File extends FileSystemItemAbstract

  require: false

  to_filename: (filename, ext) -> filename + '.' + ext

  constructor: (@options) ->

    super
    if @filenamesOnly
      (@output = {})[@path] = (path.match /\/(?!.*\/).*/)[0].substring 1
      return

    if _.include IMAGE_FORMATS, @get_extension(@path).toLowerCase()
      @binary ?= then 'binary'

    @_watch()
    @process()

  read: ->
    try
      @compiled = @contents = fs.readFileSync(@path, @binary).toString()
      @compiled = @compile.call this if @compile
    catch er
      console.log 'unwatch ', @path

      if _.contains(@watched_files, @path)
        @watched_files.splice _.indexOf(@watched_files, @path), 1
      @fileWatcher?.close()

  process: ->

    @output = @callback?() # callback

    if requireFiles
      try
        @output = require @path
      catch er
        _.defer =>
          @output = require @path
          addToObject()

  unwatch: ->
    @fileWatcher?.close()

  _watch: ->
    return if not (@watch_handler or @freshen or @repeat_callback) or
      @watch is false or _.include(@watched_list, @path)

    @watched_list.push @path

    _.defer =>
      @fileWatcher = fs.watch @path, @_watch_handler

  _watch_handler: =>
    console.log 'file watch changed: ', arguments...

    if _.isFunction @watch_handler
      @watch_handler?({@read, @recompile, @addToObject})

    if @repeat_callback
      console.log 'repeat callback'
      @read?()
      @callback?(true) # callback

    if @freshen
      console.log 'freshen'
      @readFile?()
      @recompile?()
      @addToObject?()

module.exports = File

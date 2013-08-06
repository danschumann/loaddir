fs = require 'fs'
_ = require 'underscore'

FileSystemItemAbstract = FileSystemItemAbstract || require './file_system_item_abstract'

Directory = Directory || {}

_.defer => Directory = require './directory_class'

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

    console.log 'File::constructor'.inverse + @options.path.magenta
    super

    if _.include IMAGE_FORMATS, @get_extension(@path).toLowerCase()
      @binary ?= then 'binary'

    @process()
    @start_watching()

  read: ->
    try
      @fileContents = fs.readFileSync(@path, @binary).toString()
    catch er

      if _.contains(@watched_list, @path)
        @watched_list.splice _.indexOf(@watched_list, @path), 1

      if _.contains(@file_watchers, @fileWatcher)
        @file_watchers.splice _.indexOf(@file_watchers, @fileWatcher), 1
      @fileWatcher?.close()

  process: ->

    console.log 'File::process'.inverse + @path.magenta
    if @require
      try
        @fileContents = require @path
      catch er
        _.defer =>
          @fileContents = require @path
    else
      @read()
      @fileContents = @compile.call this if @compile
      @fileContents = @callback() if @callback

    if @destination
      fileName = @to_filename @baseName, @extension || @get_extension @fileName
      fs.writeFileSync @destination, @fileContents, @binary

    # We wrap our fileContents with the filename for consistency
    key = (if @as_object then '' else @relativePath) + @baseName
    @output[key] = @fileContents

  unwatch: ->
    @fileWatcher?.close()

  start_watching: ->
    return if @watch is false or _.include(@watched_list, @path)
    console.log 'start_watching'.cyan + @path.magenta if @options.debug

    @watched_list.push @path
    @file_watchers.push @fileWatcher = fs.watch @path, @watchHandler

  watchHandler: =>

    console.log 'watchHandler'.cyan + @path.magenta if @options.debug
    @process()

module.exports = File

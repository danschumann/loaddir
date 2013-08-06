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

    console.log 'File::constructor'.inverse + @options.path.magenta if @options.debug
    super

    if _.include IMAGE_FORMATS, @get_extension(@path).toLowerCase()
      @binary ?= then 'binary'

    @process()

  read: ->
    console.log 'File::read'.inverse, @path.magenta
    try
      @fileContents = fs.readFileSync(@path, @binary).toString()
      true
    catch er
      console.log "Could not read, file erased?".red

      if _.contains(@watched_list, @path)
        @watched_list.splice _.indexOf(@watched_list, @path), 1

      #if _.contains(@file_watchers, @fileWatcher)
      #  @file_watchers.splice _.indexOf(@file_watchers, @fileWatcher), 1
      delete @options.parent.children[@path]
      delete @output[@key]
      fs.unwatchFile @path
      #@fileWatcher?.close()
      false

  process: ->

    console.log 'File::process'.inverse + @path.magenta if @options.debug
    if @require
      try
        @fileContents = require @path
      catch er
        _.defer =>
          @fileContents = require @path
    else
      return if @read() is false
      @fileContents = @compile(this) if @compile
      @fileContents = @callback(this) if @callback

    if @destination
      write_path = @to_filename @trim_ext(@destination), @extension || @get_extension @fileName
      fs.writeFileSync write_path, @fileContents, @binary

    # We wrap our fileContents with the filename for consistency
    @key = (if @as_object then '' else @relativePath) + @baseName
    @output[@key] = @fileContents
    @start_watching()


  start_watching: ->
    return if @watch is false or _.include(@watched_list, @path)
    console.log 'File::start_watching'.inverse + @options.path.magenta if @options.debug

    @watched_list.push @path
    #@file_watchers.push @fileWatcher =
    fs.watchFile @path, @watchHandler

  watchHandler: =>

    console.log 'File::watchHandler'.inverse + @options.path.magenta if @options.debug
    @process()

module.exports = File

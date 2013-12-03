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
  is_file: true

  to_filename: (filename, ext) -> filename + '.' + ext

  constructor: (@options) ->

    # debounce so that hopefully the file is done being written to disk -- longer files may need more
    @watchHandler = _.debounce @watchHandler, 500
    console.log 'File::constructor'.inverse + @options.path.magenta if @options.debug
    super

    if _.include IMAGE_FORMATS, @get_extension(@path).toLowerCase()
      @binary ?= 'binary'

    @process()

  read: ->
    console.log 'File::read'.inverse, @path.magenta if @options.debug
    try
      @fileContents = fs.readFileSync(@path, @binary).toString()
      true
    catch er
      console.log "Could not read, file erased?".red

      if _.contains(@watched_list, @path)
        @watched_list.splice _.indexOf(@watched_list, @path), 1

      delete @options.parent.children[@path]
      delete @output[@key]
      if @fast_watch
        if _.contains(@file_watchers, @fileWatcher)
          @file_watchers.splice _.indexOf(@file_watchers, @fileWatcher), 1
        @fileWatcher?.close()
      else
        fs.unwatchFile @path
      false

  process: ->

    console.log 'File::process'.inverse + @path.magenta if @options.debug
    if @require
      @fileContents = require @path
    else
      return if @read() is false
      try
        @fileContents = @compile(this) if @compile
      catch er
        console.log "We had an error compiling".red, er, @path
      try
        @fileContents = @callback(this) if @callback
      catch er
        console.log "We had an error calling back".red, er, @path

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
    if @fast_watch
      @file_watchers.push @fileWatcher = fs.watch @path, @watchHandler
    else
      fs.watchFile @path, @watchHandler

  watchHandler: =>

    console.log 'File::watchHandler'.inverse + @options.path.magenta if @options.debug

    @process()

module.exports = File

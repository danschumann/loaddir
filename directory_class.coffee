fs = require 'fs'
_ = require 'underscore'
CoffeeScript = require 'coffee-script'
colors = require 'colors'

FileSystemItemAbstract = require './file_system_item_abstract'
File = require './file_class'

class Directory extends FileSystemItemAbstract

  as_object: false
  recursive: true

  constructor: (@options) ->

    # used for exposed_hooks if they want to receive these instances back
    @children = @options.children ? {}

    @options.recursive ?= true

    console.log 'Directory::constructor'.yellow, @options.path.green if @options.debug
    @options.watched_list ?= []
    @options.file_watchers ?= []

    super

    @extractSingleUseOptions()

    if @relativePath?
      @relativePath += @baseName + '/'
    else
      @relativePath = ''

    if @destination
      try
        fs.lstatSync @destination
      catch er
        fs.mkdirSync @destination

    if @top or @recursive
      @start_watching()
      @process()

  process: ->
    console.log 'Directory::process'.yellow, @path.green if @options.debug
    @readdirResults = fs.readdirSync @path
    _.map @readdirResults, @processChild

  # Loop through all files and load them as well
  processChild: (fileName) =>
    console.log 'Directory::processChild'.yellow, fileName.green if @options.debug

    return if @white_list and !_.include @white_list, fileName
    return if @black_list and _.include @black_list, fileName
    return if fileName.charAt(0) is '.'

    path = @path + '/' + fileName
    baseName = @trim_ext fileName

    options = _.extend (_.clone @options),
      path: path
      fileName: fileName
      destination: if @destination then @destination + '/' + fileName
      children: if @options.exposed_hooks is 'array' or !@as_object then @children
      relativePath: @relativePath
      baseName: baseName

    File ?= require

    stats = fs.lstatSync( path )
    if stats.isDirectory()
      options.output = if @as_object
          @output[baseName] = {}
        else
          @output
      Class = Directory
    else
      options.output = @output
      Class = File

    child = new Class options

    if @options.exposed_hooks isnt 'array' and @as_object
      @children[baseName] = child
    else
      @children[path] = child

  start_watching: ->
    return if @watch is false or @watch is 'files' or _.include(@watched_list, @path)

    @watched_list.push @path
    folderContentsBefore = JSON.stringify @readdirResults
    _.defer =>
      @file_watchers.push @fileWatcher = fs.watch @path, @watchHandler

  watchHandler: =>

    console.log 'Directory::watchHandler', arguments...
    folderContentsAfter = JSON.stringify fs.readdirSync @path
    @process() if folderContentsBefore isnt folderContentsAfter
    @restart() if @watch_handler is 'restart'

  unwatch: -> @fileWatcher?.close()

module.exports = Directory

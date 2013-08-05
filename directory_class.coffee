FileSystemItemAbstract = require './file_system_item_abstract_class'
File = require './file_class'
fs = require 'fs'
_ = require 'underscore'

class Directory extends FileSystemItemAbstract

  as_object: false
  recursive: true

  constructor: (@options) ->

    @options.watched_list ?= []
    @output = {}

    super

    @extractSingleUseOptions()

    @relativePath ?= ''
    super

    if @destination
      try
        fs.lstatSync @destination
      catch er
        fs.mkdirSync @destination

    if @top or @recursive
      @_watch()
      @process()

  process: ->
    @readdirResults = fs.readdirSync @path
    _.map @readdirResults, @processChild

  # Loop through all files and load them as well
  processChild: (fileName) =>
    return if white_list and !_.include white_list, fileName
    return if black_list and _.include black_list, fileName
    return if fileName.charAt(0) is '.'

    path = @path + '/' + fileName

    stats = fs.lstatSync( path )

    if @recursive
      Class = if stats.isDirectory() then Directory else File

      {output} = new Class _.extend @options,
        path: path
        destination: @destination + '/' + fileName
        relativePath: @relativePath + fileName + '/'
        baseName: @trim_ext fileName

    if @as_object
      @output[fileName] = output
    else
      _.extend @output, output

  _watch: ->
    return if not (@watch_handler or @freshen or @repeat_callback) or
      @watch is false or @watch is 'files' or _.include(@watched_list, @path)

    @watched_list.push @path
    folderContentsBefore = JSON.stringify @readdirResults
    _.defer =>
      @fileWatcher = fs.watch @path, @_watch_handler

  _watch_handler: =>

    console.log 'directory watch changed: ', arguments...
    folderContentsAfter = JSON.stringify fs.readdirSync @path
    @process() if folderContentsBefore isnt folderContentsAfter
    @restart() if @watch_handler is 'restart'

  unwatch: -> @fileWatcher?.close()

module.exports = Directory

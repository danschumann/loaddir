_ = require 'underscore'
fs = require 'fs'
child = require 'child_process'
CoffeeScript = require 'coffee-script'
{extension, trim_ext} = require './string_helper'

File = require './file_class'
Directory = require './directory_class'

module.exports = loaddir = (options = {}) ->

  #depreciations
  options.watch_handler ?= options.on_change

  # Then we pull everything out
  {
    again
    as_object
    binary
    black_list
    callback
    compile
    destination
    extension: _to_ext
    filenamesOnly
    freshen
    on_change
    path
    recursive
    relativePath
    repeat_callback
    require: requireFiles #require is reserved
    to_filename
    watch
    watch_handler
    white_list
    top_level
  } = options

  # Extensions should all just be the same ( no dot )
  if _to_ext and _to_ext[0] is '.'
    _to_ext = _to_ext.substring 1

  # strip ending slash for consistency
  options.path = options.path.slice 0, -1 if '/' is _.last options.path

  #parent_path = (path.match /.*\//)[0].slice 0, -1
  #baseName = (path.match /\/(?!.*\/).*/)[0].substring 1
  
  return (new Directory options).output

  # the wholeProcess may be repeated again if a new file is created in a dir
  filenames = _.map fs.readdirSync(parent_path), (fileName) ->
    do wholeProcess = (_again = false) =>
      
      formatted_filename = to_filename trimmedFN, _to_ext || extension fileName
      _changedFileName = destDir + formatted_filename

      if destination?

        do recompile = =>
          fs.writeFileSync _changedFileName, compiled, binary

      do addToObject = =>
        if as_object
          output[trimmedFN] = _.extend (_required ? compiled), output[trimmedFN]
        else
          output[(relativePath ? '') + trimmedFN] = _required ? compiled
    fileName

  if top_level and as_object
    return output[dirName]
  else
    return output

# Note untested
loaddir.restartServer = ->
  fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()
  require './loaddir_tmp_restart'
  fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()

loaddir.watched_files = []


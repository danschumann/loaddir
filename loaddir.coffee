_ = require 'underscore'
fs = require 'fs'
child = require 'child_process'
CoffeeScript = require 'coffee-script'
{extension, trim_ext} = require './string_helper'

# by default, we do not change the extension when copying
_to_filename = (filename, ext) -> return [filename, ext].join('.')


module.exports = loaddir = (options = {}) ->

  # We do defaults on the options object because it will be passed recursively
  options.as_object ?= false
  options.recursive ?= true
  options.to_filename ?= _to_filename
  options.require ?= false
  options.relativePath ?= ''
  options.watch ?= true

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
    white_list
  } = options

  output = {}

  if _to_ext and _to_ext[0] is '.'
    _to_ext = _to_ext.substring 1

  # strip ending slash for consistency
  path = path.slice 0, -1 if '/' is _.last path

  # the wholeProcess may be repeated again if a new file is created in a dir
  _.each fs.readdirSync(path), (fileName)-> do wholeProcess = (_again = false) =>
      
    return if black_list and _.include black_list, fileName
    return if white_list and !_.include white_list, fileName
    return if fileName.charAt(0) is '.'

    trimmedFN = trim_ext fileName

    fullPath = "#{path}/#{fileName}"
    
    destDir = destination + '/' + (relativePath ? '')

    stats = fs.lstatSync( fullPath )

    if stats.isDirectory()

      # we ensure a folder to write to
      if destination
        try
          fs.lstatSync destDir + '/' + fileName
          #console.log "-rf #{destDir}#{fileName}/*"
          if _again
            child.exec "rm -rf #{destDir}#{fileName}/*", =>
              console.log 'DELETED', arguments...
          
        catch er
          fs.mkdirSync destDir + '/' + fileName

      if (on_change or freshen or repeat_callback) and not _again then _.defer =>
        fs.watch fullPath, => wholeProcess true

      if recursive
        loadedChildren = loaddir _.extend _.clone(options),
            path: fullPath
            white_list: false
            relativePath: (relativePath ? '') + fileName + '/'
            again: _again
        if as_object
          output[trimmedFN] = _.extend output[trimmedFN] ?{}, loadedChildren
        else
          output = _.extend loadedChildren, output
      return

    if (on_change or freshen or repeat_callback) and not again then _.defer =>

      # without a delay sometimes with long files it won't pick up the entire file
      fs.watch fullPath, => _.delay( =>
        console.log {fileName}

        loaddir.restartServer() if on_change is 'restart'

        console.log 'recompilin'
        if repeat_callback
          console.log 'refreshen'
          readFile?()
          process?(true)
        if _.isFunction on_change
          on_change?({readFile, recompile, addToObject})
        if freshen
          console.log 'refreshen'
          readFile?()
          recompile?()
          addToObject?()
      , 250)

    # We break the compiler alot
    #console.log 'loaddir 120', fullPath, fileName

    # Get file and compile
    compiled = ''
    return output[trimmedFN] = {} if filenamesOnly

    image_formats = ['png', 'jpg', 'gif', 'jpeg']
    binary ?= if (_ image_formats).include(extension(fullPath).toLowerCase()) then 'binary'

    do readFile = =>
      contents = fs.readFileSync(fullPath, binary).toString()
      compiled = compile?(contents, fullPath) ? contents

    # Callback for all options and data
    if _.isFunction callback
      do process = (repeat = false) =>
        compiled = callback _.extend _.clone(options), {compiled, relativePath, fileName, fullPath, repeat}

    if requireFiles
      try
        require fullPath
      catch er
        _.defer => require fullPath

    formatted_filename = to_filename trimmedFN, _to_ext || extension fileName
    _changedFileName = destDir + formatted_filename

    if destination?

      do recompile = =>
        fs.writeFileSync _changedFileName, compiled, binary

    do addToObject = =>
      if as_object
        output[trimmedFN] = _.extend compiled, output[trimmedFN]
      else
        output[(relativePath ? '') + trimmedFN] = compiled

  return output

# Note untested
loaddir.restartServer = ->
  fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()
  require './loaddir_tmp_restart'
  fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()

_ = require 'underscore'
fs = require 'fs'
child = require 'child_process'
CoffeeScript = require 'coffee-script'
{extension, trim_ext} = require './string_helper'

# default 
_to_filename = (filename, ext) -> return [filename, ext].join('.')

module.exports = loadDir = (options = {}) ->
  {white_list, black_list, destination, compile, to_filename, relativePath, callback, filenamesOnly, priority, freshen, reprocess, binary } = options

  # template.directory.filename() vs template['directory/filename']
  options.as_object ?= false
  options.recursive ?= true
  options.to_filename ?= _to_filename
  options.require ?= false

  as_object = options.as_object
  recursive = options.recursive

  path = options.path

  on_change = options.on_change

  destination = options.destination

  compile = options.compile

  callback = options.callback

  to_filename = options.to_filename

  requireFiles = options.require

  #   filenamesOnly
  #
  # if output should be formatted using only the lowest level filenames

  args = arguments[0]

  relativePath ?= ''
  _xp = {}

  # all paths should be the same -- no ending slash
  path = path.slice 0, -1 if '/' is _.last path

  _changedTimes = {}

  _.each fs.readdirSync(path), (fileName)-> do wholeProcess = (again = false) =>
      
    return if black_list and _.include black_list, fileName
    return if white_list and !_.include white_list, fileName
    return if fileName.charAt(0) is '.'

    trimmedFN = trim_ext fileName

    fullPath = "#{path}/#{fileName}"
    
    _destDir = destination + '/' + (relativePath ? '')

    stats = fs.lstatSync( fullPath )
    _fileTime = stats.ctime.getTime()
    if _changedTimes[fullPath] is _fileTime
      console.log 'returning'
      return 
    _changedTimes[fullPath] = _fileTime

    if stats.isDirectory()

      # we ensure a folder to write to
      if destination
        try
          fs.lstatSync _destDir + '/' + fileName
          #console.log "-rf #{_destDir}#{fileName}/*"
          if again
            child.exec "rm -rf #{_destDir}#{fileName}/*", =>
              console.log 'DELETED', arguments...
          
        catch er
          fs.mkdirSync _destDir + '/' + fileName

      fs.watch fullPath, => wholeProcess true

      if recursive
        loadedChildren = loadDir _.extend _.clone(args),
            path: fullPath
            white_list: false
            relativePath: (relativePath ? '') + fileName + '/'
        if as_object
          _xp[trimmedFN] = _.extend _xp[trimmedFN] ?{}, loadedChildren
        else
          _xp = _.extend loadedChildren, _xp
      return

    if on_change or freshen or reprocess then _.defer =>

      # without a delay sometimes with long files it won't pick up the entire file
      fs.watch fullPath, => _.delay( =>

        loadDir.restartServer() if on_change is 'restart'

        console.log 'recompilin'
        if reprocess
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
    #console.log 'loadDir 120', fullPath, fileName

    # Get file and compile
    compiled = ''
    return _xp[trimmedFN] = {} if filenamesOnly

    image_formats = ['png', 'jpg', 'gif', 'jpeg']
    binary ?= if (_ image_formats).include(extension(fullPath).toLowerCase()) then 'binary'

    do readFile = =>
      contents = fs.readFileSync(fullPath, binary).toString()
      compiled = compile?(contents, fullPath) ? contents

    # Callback for all args and data
    if _.isFunction callback
      do process = (reloaded = false) =>
        compiled = callback _.extend _.clone(args), {compiled, relativePath, fileName, fullPath, reloaded}

    if requireFiles
      try
        require fullPath
      catch er
        _.defer => require fullPath

    formatted_filename = to_filename trimmedFN, extension fileName
    _changedFileName = _destDir + formatted_filename

    if destination?

      do recompile = =>
        fs.writeFileSync _changedFileName, compiled, binary

    do addToObject = =>
      if as_object?
        _xp[(relativePath ? '') + formatted_filename] = compiled
      else
        _xp[formatted_filename] = _.extend compiled, _xp[formatted_filename]

  _xp

loadDir.restartServer = ->
  fs.writeFileSync 'loadDir_tmp_restart.txt', Math.random()
  require 'loadDir_tmp_restart.txt'
  fs.writeFileSync 'loadDir_tmp_restart.txt', Math.random()

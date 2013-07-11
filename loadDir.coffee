_ = require 'underscore'
fs = require 'fs'

module.exports = loadDir = (options = {}) ->
  {white_list, black_list, destination, compile, extension, relativePath, callback, requireFiles, filenamesOnly, priority, freshen, reprocess, binary } = options

  # template.directory.filename() vs template['directory/filename']
  as_object = options.as_object ? false

  recursive = options.recursive ? true

  path = options.path

  on_change = options.on_change

  destination = options.destination

  #   callback
  #
  # callback function
  # receives {compiled, relativePath, fileName, fullPath} 
  #   as well as all these named input arguments

  #   extension
  #
  # 'js' for javascript, 'css' for css, etc

  #   relativePath
  #
  # an output variable containing the directories scraped into
  # i.e. if full path is '/root/dir1/dir2/file'
  #  and path is '/root/', then relativePath is 'dir1/dir2/'
  #  or something like that (not sure on slashes)
  #  TODO: update this comment with accurate slashes

  #   requireFiles
  #
  # whether or not to use require on the fullPath
  # bool

  #   filenamesOnly
  #
  # if output should be formatted using only the lowest level filenames

  #   freshen
  #
  # whether or not to read the file again and write it to disk
  # if it changes
  # bool

  #   reprocess
  #
  # whether or not to read the file and run callback again
  # if it changes
  # callback receives an additional reprocess: true named argument
  #  so that you know if it's running a 2nd time or not
  # bool

  args = arguments[0]

  recursive ?= true

  relativePath ?= ''
  _xp = {}

  _.map fs.readdirSync(path), (fileName)->
    if white_list
      console.log {fileName}
      console.log color 'ASDF', 'red'
    return if black_list? and _.include black_list, fileName
    return if white_list? and !_.include white_list, fileName
    return if fileName.charAt(0) is '.'

    trimmedFN = fileName.trim_ext()
    fullPath = "#{path}/#{fileName}"

    if fs.lstatSync( fullPath ).isDirectory()
      if recursive
        deepContents = loadDir _.extend _.clone(args),
            path: fullPath
            relativePath: (relativePath ? '')+fileName+'/'
        if as_object
          _xp[trimmedFN] = _.extend _xp[trimmedFN] ?{}, deepContents
        else
          _xp = _.extend deepContents, _xp
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
        if freshen
          console.log 'refreshen'
          readFile?()
          recompile?()
          addToObject?()
      , 250)
        

    # We break the compiler alot
    console.log 'loadDir 120', fullPath, fileName

    # Get file and compile
    compiled = ''
    return _xp[trimmedFN] = {} if filenamesOnly

    image_formats = ['png', 'jpg', 'gif', 'jpeg']
    extension ?= fullPath.extension()
    binary ?= if (_ image_formats).include(fullPath.extension().toLowerCase()) then 'binary'

    do readFile = =>
      contents = fs.readFileSync(fullPath, binary).toString()
      compiled = compile?(contents) ? contents

    # Callback for all args and data
    if _.isFunction callback
      do process = (reloaded = false) =>
        compiled = callback _.extend _.clone(args), {compiled, relativePath, fileName, fullPath, reloaded}

    if requireFiles
      try
        require fullPath
      catch er
        _.defer => require fullPath

    # Write to dir with new extension
    _writeDir = destination + '/' + (relativePath ? '')

    _changedFileName = _writeDir + trimmedFN + '.' + extension

    if destination?
      try
        fs.lstatSync _writeDir
      catch er
        fs.mkdirSync _writeDir

      do recompile = =>
        fs.writeFileSync _changedFileName, compiled, binary
        #fs.chownSync _changedFileName, 222, 500

    do addToObject = =>
      if as_object?
        _xp[(relativePath ? '') + fileName] = compiled
      else
        _xp[trimmedFN] = _.extend compiled, _xp[trimmedFN]

  _xp

loadDir.restartServer = ->
  fs.writeFileSync 'loadDir_tmp_restart.txt', Math.random()
  require 'loadDir_tmp_restart.txt'
  fs.writeFileSync 'loadDir_tmp_restart.txt', Math.random()

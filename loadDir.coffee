_ = require 'underscore'
fs = require 'fs'

module.exports = loadDir = (options = {}) ->
  {white_list, black_list, relaunchApp, destination, compileTo, compile, extension, relativeDir, withCompiled, requireFiles, filenamesOnly, priority, freshen, reprocess, binary } = options

  # template.directory.filename() vs template['directory/filename']
  as_object = options.as_object ? false

  recursive = options.recursive ? true

  path = options.path ? ''

  #   relaunchApp
  #
  # bool

  #   compileTo --> destination
  #
  # '/path/to/output'
  # bool

  #
  #   compile
  #
  # bool

  #   withCompiled
  #
  # callback function
  # receives {compiled, relativeDir, fileName, fullPath} 
  #   as well as all these named input arguments

  #   extension
  #
  # 'js' for javascript, 'css' for css, etc

  #   relativeDir
  #
  # an output variable containing the directories scraped into
  # i.e. if full path is '/root/dir1/dir2/file'
  #  and path is '/root/', then relativeDir is 'dir1/dir2/'
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
  # whether or not to read the file and run withCompiled again
  # if it changes
  # withCompiled receives an additional reprocess: true named argument
  #  so that you know if it's running a 2nd time or not
  # bool

  # depreciations
  destination ?= compileTo

  args = arguments[0]

  recursive ?= true

  relativeDir ?= ''
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
            relativeDir: (relativeDir ? '')+fileName+'/'
        if as_object
          _xp[trimmedFN] = _.extend _xp[trimmedFN] ?{}, deepContents
        else
          _xp = _.extend deepContents, _xp
      return

    if relaunchApp or freshen or reprocess then _.defer =>

      # without a delay sometimes with long files it won't pick up the entire file
      fs.watch fullPath, => _.delay( =>

        do restartExpress if relaunchApp
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
    if _.isFunction withCompiled
      do process = (again = false) =>
        compiled = withCompiled _.extend _.clone(args), {compiled, relativeDir, fileName, fullPath, again}

    if requireFiles
      try
        require fullPath
      catch er
        _.defer => require fullPath

    # Write to dir with new extension
    _writeDir = destination + '/' + (relativeDir ? '')

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
        _xp[(relativeDir ? '') + fileName] = compiled
      else
        _xp[trimmedFN] = _.extend compiled, _xp[trimmedFN]

  _xp

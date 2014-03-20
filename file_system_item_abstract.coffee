fs = require 'fs'
_ = require 'underscore'

class FileSystemItemAbstract extends Object

  get_extension: (str) ->
    str.substring( (str.lastIndexOf('.') + 1) || str.length )

  trim_ext: (str) ->
    return str unless ~str.lastIndexOf('.')
    str.substring( 0, str.lastIndexOf('.') )

  restart: ->
    fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()
    require './loaddir_tmp_restart'
    fs.writeFileSync 'loaddir_tmp_restart.txt', Math.random()

module.exports = FileSystemItemAbstract

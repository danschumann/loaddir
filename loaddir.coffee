_ = require 'underscore'
fs = require 'fs'
child = require 'child_process'
CoffeeScript = require 'coffee-script'
{extension, trim_ext} = require './string_helper'

colors = require 'colors'


File = require './file_class.coffee'
Directory = require './directory_class.coffee'

module.exports = loaddir = (options = {}) ->

  console.log 'Loaddir debug mode!'.zebra if options.debug

  #depreciations
  options.watch_handler ?= options.on_change

  # Extensions should all just be the same ( no dot )
  if options.extension and options.extension[0] is '.'
    options.extension = options.extension.substring 1

  # strip ending slash for consistency
  options.path = options.path.slice 0, -1 if '/' is _.last options.path

  options.top = true

  #parent_path = (path.match /.*\//)[0].slice 0, -1
  #baseName = (path.match /\/(?!.*\/).*/)[0].substring 1
  
  # we feed output into the class so the object doesn't get changed
  options.output = {}

  directory = new Directory options
  if options.expose_hooks
    directory
  else
    options.output

var
  loaddir      = require('../'),
  _ = require('underscore');

// context: Directory or File
module.exports = function(){
  var self = this;
  var options = this.options;

  options.debug = options.debug == null ?
      loaddir.debug
    : options.debug;

  _.each([
    'asObject',
    'binary',
    'callback',
    'compile',
    'debug',
    'baseName',
    'destination',
    'extension',
    'fastWatch',
    'fileName',
    'change',
    'path',
    'recursive',
    'relativePath',
    'repeatCallback',
    'require',
    'toFilename',
    'watch',
    'watchHandler',
    'watchedPaths',
    'watchers',
    'output',
  ], function(opt) {
    self[opt] = options[opt];
  })

};

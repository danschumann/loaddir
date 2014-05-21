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
    'callback',
    'compile',
    'debug',
    'baseName',
    'pathsOnly',
    'destination',
    'extension',
    'fastWatch',
    'fileName',
    'path',
    'recursive',
    'relativePath',
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

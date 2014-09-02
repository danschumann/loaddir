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
    'baseName',
    'black_list',
    'callback',
    'compile',
    'debug',
    'destination',
    'existingManifest',
    'extension',
    'fastWatch',
    'fileName',
    'output',
    'path',
    'pathsOnly',
    'recursive',
    'relativePath',
    'require',
    'toFilename',
    'watch',
    'watchHandler',
    'watchedPaths',
    'watchers',
  ], function(opt) {
    self[opt] = options[opt];
  })

  if (self.watch == null)
    self.watch = self.loaddir.watch;

};

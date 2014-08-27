var
  _             = require('underscore'),
  fs            = require('fs'),
  child         = require('child_process'),
  CoffeeScript  = require('coffee-script'),
  File          = require('./lib/file'),
  Directory     = require('./lib/directory');

require('colors');

// Recursive directory scraping / loading / callbacks / watching / callbacks
//   options to compile
module.exports = function(options) {

  var directory;

  options = options || {};

  if (options.debug) console.log('Loaddir debug mode!'.zebra);

  if (options.recursive == null)
    options.recursive = true;

  // normalize extensions -- no dot ( i.e. 'html', 'js')
  if (options.extension && options.extension[0] === '.')
    options.extension = options.extension.substring(1);

  // normalize path -- no ending slash
  if ('/' === _.last(options.path))
    options.path = options.path.slice(0, -1);

  // HACK: first run through uses black list and other features
  options.top = true;

  // This has all of the files added to it
  options.output = {};

  // returns Promise
  return (new Directory(options)).process();

};

module.exports.File = File;
module.exports.Directory = Directory;
File.prototype.loaddir = Directory.prototype.loaddir = module.exports;

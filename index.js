
var
  _             = require('underscore'),
  when          = require('when'),
  packageInfo   = require('./package.json'),
  fs            = require('final-fs'),
  child         = require('child_process'),
  CoffeeScript  = require('coffee-script'),
  File          = require('./lib/file'),
  Directory     = require('./lib/directory');

require('colors');

// Recursive directory scraping / loading / callbacks / watching / callbacks
//   options to compile
var loaddir = function(options) {

  var directory;

  options = options ? _.clone(options) : {};

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

  return when().then(function(){
    if (options.manifest)
      return fs.readFile(options.manifest)
  }).then(function(manifest){

    if (manifest) {
      manifest = JSON.parse(manifest)
      console.log('MANFIFESTOTOTOOTTOTO'.zebra, manifest);
    }
    options.manifest = manifest;

    // returns Promise
    var dir = new Directory(options)
    return dir.load().then(function() {
      // Top directory doesn't get stats loaded
      return fs.lstat(dir.path);
    }).then(function(stats){
      dir.stats = stats

      // Build manifest file
      if (options.manifest) {

        if (options.require) throw new Error('Cannot build a manifest for directly required files');

        console.log(dir.buildManifest());
        fs.writeFile(options.manifest, JSON.stringify(dir.buildManifest(), null, '  '));

      }

      return options.output;
    }).otherwise(function(er){
      console.log("dohh?".red, (er + '').red, er.stack);
    });
  });

};

module.exports.File = File;
module.exports.Directory = Directory;

// Save a reference to loaddir for testing loaddir options
File.prototype.loaddir = Directory.prototype.loaddir = loaddir;

loaddir.package = packageInfo;
loaddir.version = packageInfo.version;
module.exports = loaddir;

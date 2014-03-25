var
  when         = require('when'),
  fs           = require('final-fs'),
  pullOptions  = require('./pull_options'),
  pathjs       = require('path'),
  join         = require('path').join,
  Directory
  ;

Directory = function(options) {
  var self = this;

  this.options = options;

  if (options.debug)
    console.log('Directory'.yellow, 'constructor'.blue, self.path.green);
    
  // fixes issues where big files trigger watch before they're done writing
  self._watchHandler = _.debounce( _.bind(self._watchHandler, self), 500);

  options.watchedPaths  = options.watchedPaths  || [];
  options.watchers      = options.watchers      || [];

  pullOptions.call(this);

  // One time use
  _.each([ 'top', 'white_list', 'black_list'], function(key) {
    self[key] = options[key]
    delete options[key]
  });

  this.relativePath = this.relativePath == null ?
    '' : join(this.relativePath, this.baseName);

  when().then(function(){
    if (self.destination)
      return ensureDirectory(self.destination);
  })
  .then(function(){
    if (!self.top && self.recursive) self.process();
  });

  return this;

};

Directory.prototype.process = function() {
  var
    self = this,
    opts = self.options;

  if (self.debug)
    console.log('Directory'.yellow, '.process'.blue, this.path.green)

  return fs.readdir(self.path)
  .then(function(results) {
    self._watch()
    return when.map(results, _.bind(self.iterate, self));
  })
  .then(function(){
    return self.output; 
  })
  .otherwise(function(er) {
    console.log('Directory'.yellow, 'not found'.red, er);

    //if _.contains(self.watchedPaths, self.path)
      //self.watchedPaths.splice(_.indexOf(self.watchedPaths, self.path), 1);

    // NOTE: It appears directories only have 1 type of watcher
    //if (self.fastWatch) {
    if (this.watcher) {
      if (_.contains(self.watchers, self.watcher))
        self.watchers.splice(_.indexOf(self.watchers, self.watcher), 1)

      self.watcher.close();
    }
    //} else
      //fs.unwatchFile @path

    if (self.asObject)
      delete opts.parent.output[self.baseName];
    else
      delete opts.output[self.path];

  })

};

// Processes contents of directory
Directory.prototype.iterate = function(fileName){

  var self = this;
  if (self.debug)
    console.log('Directory'.yellow, 'iterate'.blue, fileName.green);

  // Child options
  var
    Class,
    path, baseName, options;

  path      = join(this.path, fileName);
  baseName  = pathjs.basename(fileName, pathjs.extname(fileName));

  if ( self.exclude(baseName, path) ) return;

  options = _.extend( _.clone(self.options), {
    path: path,
    fileName: fileName,
    parent: self,
    output: self.output,
    destination: self.destination,
    relativePath: self.relativePath,
    baseName: baseName,
  });

  File = require('./file');

  return fs.lstat( path )
  .then(function(stats) {
    if (stats.isDirectory()) {
      if (self.asObject)
        // Object functionality start a new recursive object
        // {path: {to: {file: ... }}} instead of {'path/to/file': ...}
        self.output[baseName] = options.output = {};
      // else no need to put directories on the output at all
      //   it's made up of all files { 'path/to/file.js': ..., 'path/other.js': ...}

      Class = Directory;
    } else {
      Class = require('./file');
    };

    var child = new Class(options)

    return child.process();
  });


};

// Determines which children to not include
Directory.prototype.exclude = function(fileName, path) {

  var self = this;

  // exists
  return self.output[path] || self.output[fileName] ||

  // white / black list violation
  (self.white_list && !_.include(self.white_list, fileName)) ||
  (self.black_list && _.include(self.black_list, fileName)) ||

  // tmp / git files
  (fileName.charAt(0) == '.');

};

Directory.prototype._watch = function(){

  var self = this;
  if (self.watch == false || self.watch == 'files' || self.watcher || _.include(self.watchedPaths, self.path))
    return 

  if (self.debug)
    console.log('Directory'.yellow, 'start_watching'.blue, self.path.green)

  self.watchedPaths.push(self.path);
  self.watcher = fs.watch(self.path, _.bind(self._watchHandler, self))

};

Directory.prototype._watchHandler = function(){

  if (this.debug)
    console.log('Directory'.yellow, '_watchHandler'.blue, this.options.path.green);

  if (this.watchHandler)
    this.watchHandler();
  else
    this.process();

};

function ensureDirectory(path) {

  return fs.exists(path)
  .then(function(exists) {

    if (!exists)
      return fs.mkdir(path);

  });

};

module.exports = Directory;

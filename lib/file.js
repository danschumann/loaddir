var
  when         = require('when'),
  fs           = require('final-fs'),
  pullOptions  = require('./pull_options'),
  pathjs       = require('path'),
  _            = require('underscore'),
  join         = require('path').join,
  debugBase    = require('debug'),
  debug        = debugBase('loaddir:file'),
  File
  ;

File = function(options) {

  var
    self = this;
  self.options = options;

  pullOptions.call(self);

  debug('File'.magenta, 'constructor'.blue, self.path.green);

  // large files take time to be written to disk, this prevents reading too early
  self._watchHandler = _.debounce( _.bind(self._watchHandler, self), 500);

  options.toFilename = options.toFilename || toFilename;

  if (_.include(IMAGE_FORMATS, pathjs.extname(self.path).toLowerCase()))
    self.binary = 'binary';

  return self;

};

File.prototype.process = function() {

  var self = this;

  debug('File'.magenta, 'process'.blue, this.path.green); 

  return when().then(function(){
    if (self.require) {
      self.fileContents = require(self.path);

    } else {

      return self.read()
      .then(function(){
        try {
          if (self.compile)
            self.fileContents = self.compile(this.fileContents);
        } catch (er) {
          debug('error compiling'.red, self.path.blue, er, er.stack);
        }
        try {
          if (self.callback)
            self.fileContents = self.callback(self);
        } catch (er) {
          debug('error calling back'.red, self.path.blue, er, er.stack);
        }
      });

    };
  })
  .then(function(){

    if (self.destination) {
      write_path = self.toFilename(
        join(self.destination, self.baseName),
        self.extension || pathjs.extname(self.fileName)
      );
      fs.writeFile(write_path, self.fileContents, self.binary);
    };

    // We wrap our fileContents with the filename for consistency
    self.key = join( self.asObject ? '' : self.relativePath, self.baseName );
    self.output[self.key] = self.fileContents;
    if (self.watch == true || (self.watch !== false && self.loaddir.watch !== false))
      self._watch()

  })
  // Allow delete to short circuit writing to self.output without throwing error
  .otherwise(function(er) {
    debug('Error loading file -- stack'.red, self.path.blue, er, er.stack);
  });

};

File.prototype._watch = function() {

  var self = this;
  if (_.include(self.watchedPaths, self.path)) return;

  debug('File'.magenta, 'start_watching'.blue, self.path.green);

  self.watchedPaths.push(self.path);

  if (self.fastWatch) {
    self.fileWatcher = fs.watch(self.path, self._watchHandler);
    self.watchers.push(self.fileWatcher);
  } else {
    fs.watchFile(self.path, self._watchHandler);
  };

};

File.prototype.read = function() {

  var self = this;

  debug('File'.magenta, 'read'.blue, self.path.magenta, 'Path Only: ' + self.pathsOnly);

  if (self.pathsOnly) {
    return when(self.fileContents = self.path);
  } else {
    return fs.readFile(self.path, self.binary)
    .then(function(fileContents) {
      self.fileContents = fileContents.toString();
    })
    .otherwise(function(er) {
  
      debug('Error reading file'.red, er, er.stack)
  
      if (_.contains(self.watchedPaths, self.path))
        self.watchedPaths.splice(_.indexOf(self.watchedPaths, self.path), 1);
  
      delete self.output[self.key];
  
      if (self.fast_watch) {
        if (_.contains(self.watchers, self.fileWatcher))
          self.watchers.splice(_.indexOf(self.watchers, self.fileWatcher), 1);
        self.fileWatcher && self.fileWatcher.close();
      } else
        fs.unwatchFile(self.path);
  
      throw er;
    });
  }

};

File.prototype._watchHandler = function() {

  var self = this;
  debugBase('loaddir:watch')('File'.magenta, 'watchHandler'.blue, this.path.green);

  if (self.watchHandler)
    self.watchHandler();
  else
    self.process();

}

var IMAGE_FORMATS = [
  '.png',
  '.gif',
  '.jpg',
  '.jpeg',
];

// Default is just combine the same baseName and extension
var toFilename = function(baseName, ext) {
  return baseName + ext;
};

module.exports = File;

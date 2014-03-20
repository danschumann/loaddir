var
  when         = require('when'),
  fs           = require('final-fs'),
  pullOptions  = require('./pull_options'),
  pathjs       = require('path'),
  join         = require('path').join,
  File
  ;

File = function(options) {

  var
    self = this;
  self.options = options;

  pullOptions.call(self);

  if (self.debug)
    console.log('File'.magenta, 'constructor'.blue, self.path.green);

  // large files take time to be written to disk, this prevents reading too early
  self._watchHandler = _.debounce( _.bind(self._watchHandler, self), 500);

  options.toFilename = options.toFilename || toFilename;

  if (_.include(IMAGE_FORMATS, pathjs.extname(self.path).toLowerCase()))
    self.binary = 'binary';

  return self;

};

File.prototype.process = function() {

  var self = this;

  if (self.debug)
    console.log('File'.magenta, 'process'.blue, this.path.green); 

  return when().then(function(){
    if (self.require) {
      self.fileContents = require(self.path);

    } else {

      return self.read()
      .then(function(){
        if (self.compile)
          self.fileContents = self.compile(this.fileContents);
        //catch er console.log "We had an error compiling".red, er, @path
        if (self.callback)
          self.fileContents = self.callback(self);
        //catch er console.log "We had an error calling back".red, er, @path
      })

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
    self._watch()

  })
  // Allow delete to short circuit writing to self.output without throwing error
  .otherwise(function() {});

};

File.prototype._watch = function() {

  var self = this;
  if (self.watch == false || _.include(self.watchedPaths, self.path)) return;

  if (self.debug)
    console.log('File'.magenta, 'start_watching'.blue, self.path.green);

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

  if (self.debug)
    console.log('File'.magenta, 'read'.blue, self.path.magenta);

  return fs.readFile(self.path, self.binary)
  .then(function(fileContents) {
    self.fileContents = fileContents.toString();
  })
  .otherwise(function(er) {

    console.log('File'.magenta, "not found".red, er)

    if (_.contains(self.watchedPaths, self.path))
      self.watchedPaths.splice(_.indexOf(self.watchedPaths, self.path), 1);

    console.log('hookay'.red, self.key)
    //delete self.options.parent.children[self.path]
    delete self.output[self.key];

    if (self.fast_watch) {
      if (_.contains(self.watchers, self.fileWatcher))
        self.watchers.splice(_.indexOf(self.watchers, self.fileWatcher), 1);
      self.fileWatcher && self.fileWatcher.close();
    } else
      fs.unwatchFile(self.path);

    throw er;
  });

};

File.prototype._watchHandler = function() {

  var self = this;
  if (this.debug)
    console.log('File'.magenta, 'watchHandler'.blue, this.path.green);

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

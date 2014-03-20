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

  pullOptions.call(this);

  if (self.debug)
    console.log('File'.magenta, 'constructor'.blue, this.path.green);

  // large files take time to be written to disk, this prevents reading too early
  self._watchHandler = _.debounce( _.bind(self._watchHandler, self), 500);

  options.toFilename = options.toFilename || toFilename;

  if (_.include(IMAGE_FORMATS, pathjs.extname(this.path).toLowerCase()))
    this.binary = 'binary';

};

File.prototype.process = function() {

  var self = this;

  if (self.debug)
    console.log('File'.magenta, 'process'.blue, this.path.green); 

  if (self.require) {
    self.fileContents = require(self.path);

  } else {

    this.read()
    .then(function(){
      try
        @fileContents = @compile(this) if @compile
      catch er
        console.log "We had an error compiling".red, er, @path
      try
        @fileContents = @callback(this) if @callback
      catch er
        console.log "We had an error calling back".red, er, @path
    })

  }

  if @destination
    write_path = @to_filename @trim_ext(@destination), @extension || @get_extension @fileName
    fs.writeFileSync write_path, @fileContents, @binary

  # We wrap our fileContents with the filename for consistency
  @key = (if @as_object then '' else @relativePath) + @baseName
  @output[@key] = @fileContents
  @start_watching()


};

File.prototype.read = function() {

  var self = this;

  if (self.debug)
    console.log('File'.magenta, 'read'.blue, self.path.magenta);

  return fs.readFileSync(self.path, @binary)
  .then(function(fileContents) {
    self.fileContents = fileContents.toString()
  })
  .otherwise(function(er) {

    console.log('File'.magenta, "not found".red)

    if (_.contains(self.watchedPaths, self.path))
      self.watchedPaths.splice(_.indexOf(self.watchedPaths, self.path), 1);

    //delete self.options.parent.children[self.path]
    delete self.output[@key]
    if @fast_watch
      if _.contains(@file_watchers, @fileWatcher)
        @file_watchers.splice _.indexOf(@file_watchers, @fileWatcher), 1
      @fileWatcher?.close()
    else
      fs.unwatchFile @path
    false
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
  return baseName + '.' + ext;
};

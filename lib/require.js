var
  coffee        = require('coffee-script'),
  callsite      = require('callsite'),
  debug         = require('debug')('loaddir:require'),
  path          = require('path');

module.exports = function(loaddir) {
  var requireCallback;

  loaddir.require = function(_path, callback){
    var dir = path.dirname(callsite()[1].getFileName());
    if (_path.substring(0,1) == '.')
      _path = path.join(dir, _path)
    debug('loaddir.require'.red, _path);

    var d = path.dirname(_path);
    var relative = require("path").relative(dir, d);

    return loaddir({
      fastWatch: true,
      path: d,
      white_list: [path.basename(_path).replace(/\.[^\.]*$/, '')],
      callback: function () {
        if ( this._ext == '.coffee' )
          this.fileContents = coffee.compile(this.fileContents);

        this.fileContents = "var module = {exports: {}};\n" +
          'var _d = "' + dir + '"; var __dirname = "' + d + '";\n' +
          this.fileContents.replace(/require\((\'|\")([^(\1)]*)(\1)\)/g, function(match, quote, fname, quote2, offset, string){
            if (fname.substring(0,1) == '.') {
              return 'require( require("path").join("' + relative + '", "' + fname + '") )'
            } else
              return match;
          });
        callback(this.fileContents);
      },
    });

  };


};

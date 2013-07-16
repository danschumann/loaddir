loaddir.js
==========

Asset watching, handling, compiling, and insertion into page for node.js

To install run `npm install loaddir`

OPTIONS
=======

All examples assume `templates = loaddir({key: value})`

__Keys below are in the format__
`key_name : default value(type)`


`as_object : false(boolean)`
_It is prettier for back end templates to call templates as objects sometimes._
If this is true, templates will be like `templates.directory.filename()`, instead of `templates['directory/filename']()`.


`recursive : true(boolean)`
set to false for only 1 layer of scraping

`path : undefined(string)` __required__
the path of the directory to load

`on_change : undefined(string or function)`
handle what to do when a file changes.  pass `'restart'` to call `loaddir.restartServer()`

`destination : undefined(string)`
copy the files to this directoy, after formatting them using `compile`

`compile : undefined(function)`
if defined, it will receive a string of the raw file.  usage: `loaddir({compile: CoffeeScript.compile})`

`callback : undefined(function)`
do something with what is returned from compile, with all of the options.
`options` are `compiled`, `relativePath`, `fullPath`, `fileName`, `repeat`
`loaddir({callback: function(options){
  if(options.reloaded) console.log('You changed a file that was being watched');
});`

`repeat_callback : false(boolean)`
This will cause callback to be called every time the file changes

`to_filename : function(filename, extension){return filename + extension}`
a filter to run file names through so you can change the extension

`require : false(boolean)`
rather than compiling, this will require the file

`black_list : [](array of strings)`
a list of filenames to halt on

`white_list : [](array of strings)`
a list of __top level__ files that are to be used exclusively




Some examples
=============

```javascript
// load server side templates into object for use: template.index()
loaddir = require('loaddir');
jade = require('jade');

templates = loaddir({
  as_object: true,
  path: __dirname + '/templates',
  compile: function(str){
    jade.compile(str);
  }
});

// for use with express?
app.get('*', function(req, res, next) { res.send(template.my_filename(req)); });
```


in coffeescript:
```coffeescript
loaddir = require 'loaddir'
CoffeeScript = require 'coffee-script'

# compile assets to public for express to serve
loaddir
  path: __dirname + '/frontend/coffeescripts',
  destination: __dirname + '/public/javascripts'
  compile: (rawFile, fullPath) -> CoffeeScript.compile rawFile
  to_filename: (trimmedFn, original_extension) -> trimmedFn + '.js'
```



TODOS
====

# Make engine for express



PATCH NOTES
===========
`0.0.21`
fixed an issue where deleted files were throwing an error to what was watching them
`0.0.20`
removed in issue where files were being watched multiple times if a directory had new files being created or destroyed in it(even swp files were breaking it)

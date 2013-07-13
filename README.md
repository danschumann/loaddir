THIS IS UNDER DEVELOPMENT AND SHOULD BE UP IN A COUPLE DAYS
===========================================================
i know i should probably make this private

loaddir.js
==========

Asset watching, handling, compiling, and insertion into page for node.js


If you modify loadDir.coffee, run `coffee -cw loadDir.coffee` to compile and watch. That keeps loadDir.js up to date as you're editing it


OPTIONS
=======

All examples assume `templates = loadDir({key: value})`

__Keys below are in the format__
`key_name : default value(type)`


`as_object : false(boolean)`
_It is prettier for back end templates to call templates as objects sometimes._
If this is true, templates will be like `templates.directory.filename()`, instead of `templates['directory/filename']()`.


`recursive : true(boolean)`
set to false for only 1 layer of scraping

`skip : [](array)`
include file and folder names as strings to skip

`path : undefined(string)` __required__
the path of the directory to load

`on_change : undefined(string or function)`
handle what to do when a file changes.  pass `'restart'` to call `loadDir.restartServer()`

`destination : undefined(string)`
copy the files to this directoy, after formatting them using `compile`

`compile : undefined(function)`
if defined, it will receive a string of the raw file.  usage: `loadDir({compile: CoffeeScript.compile})`

`callback : undefined(function)`
do something with what is returned from compile, with all of the options.
`options` are `compiled`, `relativePath`, `fullPath`, `fileName`, `repeat`
`loadDir({callback: function(options){
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

INTERNAL NOTES
==============

`loadDir.restartServer()`
this is somewhat hacky, used by `loadDir({on_change: 'restart'})`
it writes a file `loadDir_tmp.txt`,  requires it and then writes it again, so whether using forever, supervisor, node-dev, or something else, it should restart the server.
when loadDir is first loaded, it checks for the file and deletes it, to hopefully keep it from being seen




Some examples
=============

```javascript
// load server side templates into object for use: template.index()
loaddir = require('loaddir');
jade = require('jade');

templates = loaddir({
  as_object: true
  path: __dirname + '/templates'
  compile: (str) ->
    jade.compile str
});

// for use with express?
app.get('*', function(req, res, next) { res.send(template.my_filename(req)); });
```

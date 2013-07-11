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

`path : ''(string)` required
the path of the directory to load

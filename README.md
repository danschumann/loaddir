loaddir.js
==========

Asset watching, handling, and compiling for node.js

To install run `npm install loaddir`

Some examples
=============

```javascript
// load server side templates into object for use: template.index()
loaddir = require('loaddir');
jade = require('jade');

loaddir({

  // outputs directories as subObjects, names are filenames
  asObject: true,

  path: __dirname + '/templates',

  // Runs 1st
  compile: function() {
    this.fileContents = jade.compile(fileContents);
  },
  // Runs 2nd
  callback: function(){
    console.log('Something loaded!', this.filePath);
  },

}).then(function(templates) {

  var outputSTR = templates.myFileName();
  
  // since we did `asObject`, directories are sub objects
  var otherSTR = templates.myDirectory.subFile()
  
  // not using `asObject`  would look like this
  // var otherSTR = templates['myDirectory/subFile']()
});

```

`callback` will be ran each time the file changes, keeping the returned `templates` object updated.


PATCH NOTES
===========

`1.0.0`
Added promises, and async handling


`0.2.12`
Everything got changed to be class based -- use `expose_hooks: true` to get instances of the classes rather than just the outputted results

`0.0.21`
fixed an issue where deleted files were throwing an error to what was watching them
`0.0.20`
removed in issue where files were being watched multiple times if a directory had new files being created or destroyed in it(even swp files were breaking it)

## License

(The MIT License)

Copyright (c) 2014 Dan Schumann

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

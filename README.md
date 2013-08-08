loaddir.js
==========

Asset watching, handling, compiling, and insertion into page for node.js

To install run `npm install loaddir`

Some examples
=============

```javascript
// load server side templates into object for use: template.index()
loaddir = require('loaddir');
jade = require('jade');

templates = loaddir({
  as_object: true,
  path: __dirname + '/templates',
  compile: function(){
    jade.compile(this.fileContents);
  }
});

```

in coffeescript:
```coffeescript
loaddir = require 'loaddir'
CoffeeScript = require 'coffee-script'

# compile assets to public for express to serve
loaddir
  path: __dirname + '/frontend/coffeescripts',
  destination: __dirname + '/public/javascripts'
  compile: -> CoffeeScript.compile @fileContents
  to_filename: -> @baseName + '.js'
```

PATCH NOTES
===========
`0.2.12`
Everything got changed to be class based -- use `expose_hooks: true` to get instances of the classes rather than just the outputted results

`0.0.21`
fixed an issue where deleted files were throwing an error to what was watching them
`0.0.20`
removed in issue where files were being watched multiple times if a directory had new files being created or destroyed in it(even swp files were breaking it)

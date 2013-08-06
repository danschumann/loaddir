fs = require 'fs'
loaddir = require __dirname + '/../loaddir'
_ = require 'underscore'
CoffeScript = require 'coffee-script'

{exec} = require 'child_process'

describe 'LOADDIR', ->

  FILE = 'div ->\n  \'hello world\''
  CHANGED_FILE = 'div ->\n  \'hello changed!\''
  CHANGED_COMPILED = CoffeScript.compile CHANGED_FILE
  ANOTHER = 'div ->\n  \'hello coffee\''
  INNER = 'div ->\n  \'hello inner\''

  PATH = __dirname + '/sample_path'
  DESTINATION = __dirname + '/sample_destination'

  beforeEach ->
    console.log __dirname

    # Clear Folders
    exec "rm -rf #{__dirname}/sample_destination/*; rm -rf #{__dirname}/sample_path/*; mkdir #{__dirname}/sample_path/subfolder", (=> @deleted = true)
    waitsFor (=> @deleted == true), 'Could not delete', 10000

    runs =>
      # Refill
      fs.writeFileSync __dirname + '/sample_path/file.coffee', FILE
      fs.writeFileSync __dirname + '/sample_path/Another_file.coffee', ANOTHER
      fs.writeFileSync __dirname + '/sample_path/subfolder/inner_file.coffee', INNER

  it 'has long keys', ->

    @loaddir_result = loaddir
      debug: true
      path: PATH
      watch: false
    console.log @loaddir_result

    expect(@loaddir_result).toEqual
      file: FILE
      Another_file: ANOTHER
      'subfolder/inner_file': INNER

  it 'has object keys', ->

    @loaddir_result = loaddir
      as_object: true
      path: PATH
      watch: false
    console.log @loaddir_result

    expect(@loaddir_result).toEqual
      file: FILE
      Another_file: ANOTHER
      subfolder:
        inner_file: INNER

  it 'can copy to a destination with a different extension', ->

    expect((fs.readdirSync DESTINATION).length).toBeFalsy()

    @loaddir_result = loaddir
      as_object: true
      path: PATH
      destination: DESTINATION
      extension: 'js'
      watch: false
      debug: true
    console.log @loaddir_result

    expect(fs.readdirSync DESTINATION).toEqual [
      'Another_file.js'
      'file.js'
      'subfolder'
    ]

    expect(fs.readdirSync DESTINATION + '/subfolder').toEqual [
      'inner_file.js'
    ]

    expect(@loaddir_result).toEqual
      file: FILE
      Another_file: ANOTHER
      subfolder:
        inner_file: INNER

  describe 'can watch files and compress them', ->

    beforeEach ->
      {output: @loaddir_result}  = @loaddir_instance = loaddir
        debug: true
        path: PATH
        expose_hooks: 'array'
        destination: DESTINATION

        compile: -> CoffeScript.compile @fileContents
        #freshen: true

      expect(@loaddir_result).toEqual
        file: CoffeScript.compile FILE
        Another_file: CoffeScript.compile ANOTHER
        'subfolder/inner_file': CoffeScript.compile INNER

      fs.writeFileSync __dirname + '/sample_path/file.coffee', CHANGED_FILE
      fs.writeFileSync __dirname + '/sample_path/new_file.coffee', FILE
      waitsFor =>
        #console.log @loaddir_result.new_file
        @loaddir_result.file == CoffeScript.compile CHANGED_FILE
        @loaddir_result.new_file == CoffeScript.compile FILE
      , "it didn't change when we changed the file", 2000

      deleted_another = false
      runs =>
        console.log 'removing another_file'.red
        exec "rm #{__dirname}/sample_path/Another_file.coffee", =>
          deleted_another = true
          console.log 'RUNS?'

      waitsFor =>
        deleted_another and not @loaddir_result.Another_file
      , "it to realize we erased a file", 2000

      runs =>
        console.log 'adding back another_file'.green
        _.defer => fs.writeFileSync __dirname + '/sample_path/Another_file.coffee', ANOTHER

      waitsFor =>
        #console.log @loaddir_result.Another_file
        @loaddir_result.Another_file == CoffeScript.compile ANOTHER
      , 'it realize we added the file back', 2000

      runs =>
        console.log 'updating another_file'.yellow
        fs.writeFileSync __dirname + '/sample_path/Another_file.coffee', CHANGED_FILE

      waitsFor =>
        @loaddir_result.Another_file == CoffeScript.compile CHANGED_FILE
      , 'it to successfully watch the file even though its been added recently', 2000

      console.log 'WRITING'

    it 'updates the file system as well', ->
      read_file = expect (fs.readFileSync DESTINATION + '/file.coffee').toString()
      read_file.toBe CoffeScript.compile CHANGED_FILE

      read_file = expect (fs.readFileSync DESTINATION + '/new_file.coffee').toString()
      read_file.toBe CoffeScript.compile FILE

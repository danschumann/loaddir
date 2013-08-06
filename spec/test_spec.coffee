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

    # Setup Test Files
    fs.writeFileSync __dirname + '/sample_path/file.coffee', FILE
    fs.writeFileSync __dirname + '/sample_path/Another_file.coffee', ANOTHER
    fs.writeFileSync __dirname + '/sample_path/subfolder/inner_file.coffee', INNER

    # Clear destination
    exec "rm -rf #{__dirname}/sample_destination/*", (=> @deleted = true)
    waitsFor (=> @deleted == true), 'Could not delete', 10000

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

  it 'can copy to a destination', ->

    expect((fs.readdirSync DESTINATION).length).toBeFalsy()

    @loaddir_result = loaddir
      as_object: true
      path: PATH
      destination: DESTINATION
      watch: false
      debug: true
    console.log @loaddir_result

    expect(fs.readdirSync DESTINATION).toEqual [
      'Another_file.coffee'
      'file.coffee'
      'subfolder'
    ]

    expect(fs.readdirSync DESTINATION + '/subfolder').toEqual [
      'inner_file.coffee'
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

      waitsFor =>
        #console.log @loaddir_result
        @loaddir_result.file == CoffeScript.compile CHANGED_FILE
      , "it didn't change when we changed the file", 2000
      console.log 'WRITING'
      fs.writeFileSync __dirname + '/sample_path/file.coffee', CHANGED_FILE

    it 'updates the file system as well', ->
      read_file = expect (fs.readFileSync DESTINATION + '/file.coffee').toString()
      read_file.toBe CoffeScript.compile CHANGED_FILE

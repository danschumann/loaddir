module.exports = StringHelper =

  capitalize: (str) ->
    str.charAt(0).toUpperCase() + str.substring(1)

  is_swp: ->
    (str.charAt(0) == '.' || ~str.lastIndexOf('/.'))

  isnt_requireable: ->
    str.indexOf('.') < 1

  file_name: ->
    str.substring str.lastIndexOf '/'

  is_dir:->
    str.file_name().lastIndexOf('.') == -1

  extension: (str) ->
    str.substring( (str.lastIndexOf('.') + 1) || str.length )

  trim_ext: (str) ->
    return str unless ~str.lastIndexOf('.')
    str.substring( 0, str.lastIndexOf('.') )

  toI: (str) ->
    int = (str.replace /[\D]/g, '')
    return 0 if int == ''
    (parseInt int, 10)
  
  # tab every line x spaces over ( slow for multiple spaces )
  tab: (str, num_spaces)->
    spaces=[]
    for [0..num_spaces]
      spaces.push(' ')
    spaces=spaces.join ''
    spaces+ str.replace /\n/gi, '\n'+spaces

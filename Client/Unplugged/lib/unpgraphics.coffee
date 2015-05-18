class window.UnpColor
  constructor: (@Red, @Green, @Blue, @Alpha) ->
  getValue: ->
    return 'rgba(' + @Red + ','  + @Green +  ','  + @Blue +  ','  + @Alpha +  ')'

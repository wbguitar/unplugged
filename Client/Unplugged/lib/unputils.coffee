class window.UnpUtils
  @randomHex: (howMany) ->
    if howMany == null
      howMany = 1
    _retVal = ''

    for i in [0..howMany-1]
      _cChar = ''
      _cNum = Math.floor Math.random() * 16
      if _cNum < 10
        _cChar += _cNum.toString()
      else
        switch _cNum
          when 10 then _cChar = 'a'
          when 11 then _cChar = 'b'
          when 12 then _cChar = 'c'
          when 13 then _cChar = 'd'
          when 14 then _cChar = 'e'
          when 14 then _cChar = 'f'
      _retVal += _cChar

  @randomColor: (colorFrom, colorTo) ->
    UnpUtils.colorBetween colorFrom, colorTo, Math.random()

  @colorBetween: (colorFrom, colorTo, colorPoint) ->
    if colorFrom is null
      colorFrom = new UnpColor(0, 0, 0, 1)
    if colorTo is null
      colorTo = new UnpColor(255, 255, 255, 1)
    if colorPoint is null
      colorPoint = 0.5

    _rDiff = colorTo.Red - colorFrom.Red
    _gDiff = colorTo.Green - colorFrom.Green
    _bDiff = colorTo.Blue - colorFrom.Blue
    _aDiff = colorTo.Alpha - colorFrom.Alpha

    _cRandom = Math.random()

    _rDiff = Math.round _rDiff * colorPoint
    _gDiff = Math.round _gDiff * colorPoint
    _bDiff = Math.round _bDiff * colorPoint
    _aDiff = _aDiff * colorPoint

    return new UnpColor colorFrom.Red + _rDiff, colorFrom.Green + _gDiff, colorFrom.Blue + _bDiff, colorFrom.Alpha + _aDiff

  @getQueryStringParam: (paramName) ->
    _qStringMatch = document.location.search.match(new RegExp(paramName + '=([^&]*)'))

    if _qStringMatch isnt null
      _qStringMatch = _qStringMatch[1]

    return _qStringMatch;

  @getRefreshRate: -> return 20
class window.UnpClientInit
    constructor: ->
        _queryServer = UnpUtils.getQueryStringParam 'server'
        if _queryServer is null
            #'ws://localhost:8080';
            console.log document.location.href
            window.ServerUrl = 'ws://' + document.location.hostname + ':8080'
        else
            window.ServerUrl = 'ws://' + _queryServer

        new UnpInit()
        new UnpAuth $('#unpauth-div')[0]
        new UnpChat $('#unpchat-div')[0]
        new UnpMoveIt $('#unpmoveit-div')[0]

        new UnpToolbar $('#unptoolbar-div')[0],
            [
                {
                    'text': 'visual fx',
                    'menu': [
                        {
                            'text': 'stripe array',
                            'click': ->
                                _confObj = {}
                                _confObj.startX = 100
                                _confObj.startY = 100
                                _confObj.endX = 0
                                _confObj.endY = 0
                                _confObj.color1 = 'rgba(120, 120, 120, 0.7)'
                                _confObj.color2 = 'rgba(200, 200, 200, 0.5)'
                                _confObj.stripeWidth = 60
                                _confObj.stripeNum = 5

                                _cFx = new UnpVisualFx.StripeArray $('#unpmoveit-div canvas')[0]
                                _cFx.Config(_confObj);
                                window._testVisualFx = _cFx;
                        },
                        {
                            'text': 'bezier array',
                            'click': ->
                                _confObj = {}
                                _confObj.startX = 0
                                _confObj.startY = 0
                                _confObj.endX = 0
                                _confObj.endY = 0
                                _confObj.colorFrom = new UnpColor(180, 0, 100, 0.5)
                                _confObj.colorTo = new UnpColor(0, 0, 180, 0.5)
                                _confObj.lineWidth = 3
                                _confObj.lineNum = 7

                                _cFx = new UnpVisualFx.BezierArray($('#unpmoveit-div canvas')[0])
                                _cFx.Config(_confObj)
                                window._testVisualFx = _cFx
                        },
                        {
                            'text': 'line array',
                            'click': ->
                                _confObj = {}
                                _confObj.startX = 0
                                _confObj.startY = 0
                                _confObj.endX = 0
                                _confObj.endY = 0
                                _confObj.colorFrom = new UnpColor(0, 0, 220, 0.5)
                                _confObj.colorTo = new UnpColor(220, 220, 250, 0.5)
                                _confObj.lineWidth = 1
                                _confObj.lineNum = 7

                                _cFx = new UnpVisualFx.LineArray($('#unpmoveit-div canvas')[0])
                                _cFx.Config(_confObj)
                                window._testVisualFx = _cFx
                        },
                        {
                            'text': 'timed bezier',
                            'click': ->
                                _confObj = {}
                                _confObj.startX = 0
                                _confObj.startY = 0
                                _confObj.endX = 0
                                _confObj.endY = 0
                                _confObj.lineColor = new UnpColor(180, 0, 100, 0.5)
                                _confObj.lineWidth = 3
                                _confObj.maxDist = 25

                                _cFx = new UnpVisualFx.TimedBezier($('#unpmoveit-div canvas')[0])
                                _cFx.Config(_confObj)
                                window._testVisualFx = _cFx
                        },
                        {
                            'text': 'timed bezier array',
                            'click': ->
                                _fxArray = []
                                for i in [0..9]
                                    _confObj = {}
                                    _confObj.startX = 0
                                    _confObj.startY = 0
                                    _confObj.endX = 0
                                    _confObj.endY = 0
                                    _confObj.lineColor = new UnpColor(0, 180, 50, 0.3)
                                    _confObj.lineWidth = 1 + (i % 3)
                                    _confObj.maxDist = 10

                                    _cFx = new UnpVisualFx.TimedBezier($('#unpmoveit-div canvas')[0])
                                    _cFx.Config(_confObj)
                                    _fxArray.push _cFx

                                window._testVisualFx = _fxArray
                        },
                        {
                            'text': 'timed bezier array (big)',
                            'click': ->
                                _fxArray = []
                                for i in [0..9]
                                    _confObj = {}
                                    _confObj.startX = 0
                                    _confObj.startY = 0
                                    _confObj.endX = 0
                                    _confObj.endY = 0
                                    _confObj.lineColor = new UnpColor(100, 0, 0, 0.3)
                                    _confObj.lineWidth = 3 + (i % 3)
                                    _confObj.maxDist = 200

                                    _cFx = new UnpVisualFx.TimedBezier($('#unpmoveit-div canvas')[0])
                                    _cFx.Config(_confObj)
                                    _fxArray.push _cFx

                                window._testVisualFx = _fxArray
                        },
                    ]
                },
                {
                    'text': 'particle fx',
                    'menu': [
                        {
                            'text': 'explosion',
                            'click': ->
                                _cFx = new UnpVisualFx.Explosion($('#unpmoveit-div canvas')[0])
                                window._testVisualFx = _cFx;
                        },
                        {
                            'text': 'flame',
                            'click': ->
                                _cFx = new UnpVisualFx.Flame($('#unpmoveit-div canvas')[0])
                                window._testVisualFx = _cFx;
                        },
                        {
                            'text': 'swirl',
                            'click': ->
                                _cFx = new UnpVisualFx.Swirl($('#unpmoveit-div canvas')[0])
                                window._testVisualFx = _cFx;
                        },
                        {
                            'text': 'spiral',
                            'click': ->
                                _cFx = new UnpVisualFx.Spiral($('#unpmoveit-div canvas')[0])
                                window._testVisualFx = _cFx;
                        },
                    ]
                }
            ]




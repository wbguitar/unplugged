class window.UnpVisualFxBase
    constructor: (@targetCanvas, @effectName) ->
        @configObject = {};
        @_cContext = @targetCanvas.getContext('2d');

    Config: (cfgObj) ->
        console.log
        for _ckey of cfgObj
            @configObject[_ckey] = cfgObj[_ckey];

    Draw: ->

window.UnpVisualFx = {}

class UnpVisualFx.StripeArray extends UnpVisualFxBase
    constructor: (targetCanvas) ->
        super(targetCanvas, 'StripeArray')

    _drawStripeCurve: (_pointStart, _pointEnd, _bSpace) ->
        _diffX = _pointEnd.x - _pointStart.x
        _diffY = _pointEnd.y - _pointStart.y

        _diffAngle = Math.atan2(_diffY, _diffX) + (Math.PI / 2)
        _point1 =
            x: _pointStart.x + (_bSpace * Math.cos(_diffAngle)) + (_diffX / 4)
            y: _pointStart.y + (_bSpace * Math.sin(_diffAngle)) + (_diffY / 4)
        _point2 =
            x: _point1.x + (_diffX / 2)
            y: _point1.y + (_diffY / 2)
        @_cContext.moveTo _pointStart.x, _pointStart.y
        @_cContext.bezierCurveTo(_point1.x, _point1.y, _point2.x, _point2.y, _pointEnd.x, _pointEnd.y)

    _drawStripe: (startX, startY, endX, endY, fillColor, minSpace, maxSpace)->

        @_cContext.beginPath()

        @_cContext.strokeStyle = fillColor
        @_cContext.fillStyle = fillColor
        @_cContext.lineWidth = 1

        _pointStart =
            x: startX
            y: startY
        _pointEnd =
            x: endX
            y: endY

        @_drawStripeCurve(_pointStart, _pointEnd, minSpace)
        @_drawStripeCurve(_pointEnd, _pointStart, - maxSpace)

        @_cContext.fill()
        @_cContext.closePath()

    _drawStripeArray: (startX, startY, endX, endY, color1, color2, aWidth, stripeNum) ->
        _startOffset = - (aWidth / 2)
        _sliceOffset = aWidth / stripeNum
        if color1 is null
            _cColor = color1

        @_drawStripe startX, startY, endX, endY, _cColor, _startOffset, _startOffset + aWidth
        for i in [0..stripeNum ]
            if i % 2 is 0
                continue
            else
                _cColor = color2

        _cWidthStart = _startOffset + (_sliceOffset * i)
        _cWidthEnd = _cWidthStart + _sliceOffset
        @_drawStripe startX, startY, endX, endY, _cColor, _cWidthStart, _cWidthEnd

    Draw: ->
        @_drawStripeArray @configObject.startX, @configObject.startY, @configObject.endX,
            @configObject.endY, @configObject.color1, @configObject.color2,
            @configObject.stripeWidth, @configObject.stripeNum




class UnpVisualFx.BezierArray extends UnpVisualFxBase
    constructor: (targetCanvas) ->
        super(targetCanvas, 'BezierArray')

    _drawBezierArray: (startX, startY, endX, endY, colorFrom, colorTo, lineWidth, lineNum) ->
        for i in [0..lineNum ]
            @_cContext.beginPath()
            _cLineColor = UnpUtils.randomColor(colorFrom, colorTo)
            @_cContext.strokeStyle = _cLineColor.getValue()
            @_cContext.lineWidth = Math.max(1, lineWidth * (0.5 + Math.random()))

            _distVal = 25

            _diffX = endX - startX
            _diffY = endY - startY

            _point1X = startX + (0.333 * _diffX)
            _point1Y = startY + (0.333 * _diffY)

            _point2X = startX + (0.667 * _diffX)
            _point2Y = startY + (0.667 * _diffY)

            _point1X += ((Math.random() - 0.5) * _distVal)
            _point1Y += ((Math.random() - 0.5) * _distVal)

            _point2X += ((Math.random() - 0.5) * _distVal)
            _point2Y += ((Math.random() - 0.5) * _distVal)

            @_cContext.moveTo(startX, startY)
            @_cContext.bezierCurveTo(_point1X, _point1Y, _point2X, _point2Y, endX, endY)

            @_cContext.stroke()
            @_cContext.closePath()

    Draw: ->
#        console.log('' +
#            @configObject.startX + ' '
#            @configObject.startY + ' '
#            @configObject.endX + ' '
#            @configObject.endY + ' '
#            @configObject.colorFrom + ' '
#            @configObject.colorTo + ' '
#            @configObject.lineWidth + ' '
#            @configObject.lineNum
#
#        )
        @_drawBezierArray(
            @configObject.startX,
            @configObject.startY,
            @configObject.endX,
            @configObject.endY,
            @configObject.colorFrom,
            @configObject.colorTo,
            @configObject.lineWidth,
            @configObject.lineNum)


class UnpVisualFx.LineArray extends UnpVisualFxBase
    constructor: (targetCanvas) ->
        super(targetCanvas, 'LineArray')

    _drawLineArray: (startX, startY, endX, endY, colorFrom, colorTo, lineWidth, lineNum) ->
        for i in [0..lineNum ]
            @_cContext.beginPath()

            _cLineColor = UnpUtils.randomColor(colorFrom, colorTo)

            @_cContext.strokeStyle = _cLineColor.getValue()

            @_cContext.lineWidth = Math.max(1, lineWidth * (0.5 + Math.random()))

            _distVal = 20
            _breakVal = 25

            _diffX = endX - startX
            _diffY = endY - startY

            _breakNum = Math.ceil(Math.sqrt(Math.pow(_diffX, 2) + Math.pow(_diffY, 2)) / _breakVal)

            @_cContext.moveTo(startX, startY)

            for j in [0.._breakNum ]

                _cPointX = startX + ((j / _breakNum) * _diffX)
                _cPointY = startY + ((j / _breakNum) * _diffY)

                _cPointX += ((Math.random() - 0.5) * _distVal)
                _cPointY += ((Math.random() - 0.5) * _distVal)

                @_cContext.lineTo(_cPointX, _cPointY)

            @_cContext.lineTo(endX, endY)
            @_cContext.stroke()
            @_cContext.closePath()

    Draw: ->
        console.log('' +
            @configObject.startX + ' '
            @configObject.startY + ' '
            @configObject.endX + ' '
            @configObject.endY + ' '
            @configObject.colorFrom + ' '
            @configObject.colorTo + ' '
            @configObject.lineWidth + ' '
            @configObject.lineNum

        )
        @_drawLineArray(
            @configObject.startX,
            @configObject.startY,
            @configObject.endX,
            @configObject.endY,
            @configObject.colorFrom,
            @configObject.colorTo,
            @configObject.lineWidth,
            @configObject.lineNum)




class UnpVisualFx.TimedBezier extends UnpVisualFxBase
    constructor: (targetCanvas) ->
        super(targetCanvas, 'TimedBezier')
        @_pointArray = []
        @baseConfig = @Config

    Config: (configObj) ->
        super(configObj)
        _maxDist = configObj.maxDist
        if _maxDist isnt null
            _pos1Angle = Math.random() * Math.PI * 2
            _pos2Angle = Math.random() * Math.PI * 2

            @_pointArray[0] =
                posX: Math.cos(_pos1Angle) * _maxDist * (0.5 + Math.random())
                posY: Math.sin(_pos1Angle) * _maxDist * (0.5 + Math.random())
                speedX: 0
                speedY: 0
                accX: 0
                accY:0
            @_pointArray[1] =
                posX: Math.cos(_pos2Angle) * _maxDist * (0.5 + Math.random())
                posY: Math.sin(_pos2Angle) * _maxDist * (0.5 + Math.random())
                speedX: 0
                speedY: 0
                accX: 0
                accY:0

    _drawTimedBezier: (startX, startY, endX, endY, lineColor, lineWidth) ->
        console.log
        @_cContext.beginPath();

        @_cContext.lineWidth = lineWidth;
        @_cContext.strokeStyle = lineColor.getValue();

        _diffX = endX - startX
        _diffY = endY - startY

        _point1X = startX + (_diffX * 0.333)
        _point1Y = startY + (_diffY * 0.333)
        _point2X = endX - (_diffX * 0.333)
        _point2Y = endY - (_diffY * 0.333)

        @_cContext.moveTo(startX, startY)
        @_cContext.bezierCurveTo _point1X + @_pointArray[0].posX, _point1Y + @_pointArray[0].posY,
                _point2X + @_pointArray[1].posX, _point2Y + @_pointArray[1].posY, endX, endY

        @_cContext.stroke()
        @_cContext.closePath()

    Draw: ->
        _nowTime = new Date().getTime()
        _timeDiff = UnpUtils.getRefreshRate()

        _baseAcc = 200

        for point in @_pointArray
#        for i in [0..@_pointArray.length ]
            _accAngle = Math.atan2(- point.posY, - point.posX)

            point.accX = Math.cos(_accAngle) * _baseAcc
            point.accY = Math.sin(_accAngle) * _baseAcc

            point.speedX += point.accX * _timeDiff / 1000
            point.speedY += point.accY * _timeDiff / 1000

            point.posX += point.speedX * _timeDiff / 1000
            point.posY += point.speedY * _timeDiff / 1000

        _lastUpdate = _nowTime

#        console.log('' +
#
#            @configObject.startX + ' '
#            @configObject.startY + ' '
#            @configObject.endX + ' '
#            @configObject.endY + ' '
#            @configObject.lineColor + ' '
#            @configObject.lineWidth
#
#        )

        @_drawTimedBezier(
            @configObject.startX,
            @configObject.startY,
            @configObject.endX,
            @configObject.endY,
            @configObject.lineColor,
            @configObject.lineWidth)


class UnpVisualFx.ParticleElement
    constructor: (@particleEffect) ->
        @posX = 0;
        @posY = 0;
        @speedX = 0;
        @speedY = 0;
        @accelX = 0;
        @accelY = 0;
        @color = new UnpColor(255, 255, 255);
        @width = 4;
        @height = 4;
        @creationTime = new Date().getTime();
        @texture = null;


class UnpVisualFx.ParticleEffect extends UnpVisualFxBase
    constructor: (targetCanvas, effectName) ->
        super(targetCanvas, effectName)
        @_particleArray = []
        @_lastAddDiff = 0
        @_firstUpdateTime = null
        @_totalAddedParticles = 0

    _UpdateParticles: ->
        console.log
        _timeNow = new Date().getTime()
        _timeDiff = UnpUtils.getRefreshRate()

        @_lastAddDiff += _timeDiff

        if @_firstUpdateTime is null
            @_firstUpdateTime = _timeNow

        _particleNum = @configObject.particleNum

        _particlesToRemove = []

#        arr = [0..@_particleArray.length]
#        for i in arr
#            _cParticle = @_particleArray[i]
#            if (_timeNow - _cParticle.creationTime) > @configObject.lifeSpan
#                _particlesToRemove.push(_cParticle)

        for _cParticle in @_particleArray
            if (_timeNow - _cParticle.creationTime) > @configObject.lifeSpan
                _particlesToRemove.push(_cParticle)


        for i in [0.._particlesToRemove.length ]
            for j in [0..@_particleArray.length ]
                if @_particleArray[j] is _particlesToRemove[i]
                    @_particleArray.splice(j, 1)

        if @_particleArray.length < _particleNum
            _cycleTime = @configObject.lifeSpan

            if @configObject.totalTime isnt undefined
                _cycleTime = @configObject.totalTime

            _particlesToAdd = Math.min(_particleNum - @_particleArray.length, _particleNum * (@_lastAddDiff / _cycleTime))
            _particlesToAdd = Math.floor(_particlesToAdd)

            if @configObject.totalTime isnt undefined
                if(@_totalAddedParticles > _particleNum)
                    _particlesToAdd = 0
                else
                    _particlesToAdd = Math.min(_particlesToAdd, _particleNum - @_totalAddedParticles)
                @_totalAddedParticles += _particlesToAdd

            for i in [0.._particlesToAdd]
                console.log
                _cParticle = new UnpVisualFx.ParticleElement(this)

                _cParticle.posX = @configObject.posX
                _cParticle.posY = @configObject.posY
                _cParticle.texture = @configObject.texture

                @_particleArray.push(_cParticle)
                @_lastAddDiff = 0

                @initializeParticle(_cParticle)

        for _cParticle in @_particleArray
#        for i in [0..@_particleArray.length ]
#            _cParticle = @_particleArray[i]
            _doRegularUpdate = @updateParticle(_cParticle)

            if _doRegularUpdate isnt false
                _lifePoint = (_timeNow - _cParticle.creationTime) / @configObject.lifeSpan
                _widthDiff = @configObject.endWidth - @configObject.startWidth
                _heightDiff = @configObject.endHeight - @configObject.startHeight

                _cParticle.color = UnpUtils.colorBetween(@configObject.startColor, @configObject.endColor, _lifePoint)

                _cParticle.width = @configObject.startWidth + (_widthDiff * _lifePoint)
                _cParticle.height = @configObject.startHeight + (_heightDiff * _lifePoint)

                _cParticle.speedX += _timeDiff * _cParticle.accelX / 1000
                _cParticle.speedY += _timeDiff * _cParticle.accelY / 1000

                _cParticle.posX += _timeDiff * _cParticle.speedX / 1000
                _cParticle.posY += _timeDiff * _cParticle.speedY / 1000


    initializeParticle: (cParticle) ->

    updateParticle: (cParticle) ->

    Draw: ->
        @_UpdateParticles()
        console.log
        for _cParticle in @_particleArray
#        for i in [0..@_particleArray.length
# ]
#            _cParticle = @_particleArray[i]
            _finalX = _cParticle.posX
            _finalY = _cParticle.posY

            @_cContext.beginPath()

            if _cParticle.texture is undefined
                console.log #'null texture'
                @_cContext.fillStyle = _cParticle.color.getValue()
                @_cContext.arc(_finalX, _finalY, _cParticle.width, 0, Math.PI * 2,true)
                @_cContext.fill()

            else if typeof _cParticle.texture is 'string'

                switch _cParticle.texture
                    when 'RadialFade'
                        _cGradient = @_cContext.createRadialGradient(_finalX,_finalY,0,_finalX,_finalY,_cParticle.width)

                        _cColorStart = _cParticle.color
                        _cColorEnd = new UnpColor(_cParticle.color.Red, _cParticle.color.Green, _cParticle.color.Blue, 0)

                        _cGradient.addColorStop(0, _cColorStart.getValue())
                        _cGradient.addColorStop(1, _cColorEnd.getValue())
                        @_cContext.fillStyle = _cGradient
                        @_cContext.arc(_finalX, _finalY, _cParticle.width, 0, Math.PI * 2,true)
                        @_cContext.fill()

            @_cContext.closePath()


class UnpVisualFx.Explosion extends UnpVisualFx.ParticleEffect
    constructor: (targetCanvas) ->
        super(targetCanvas, 'Explosion')
        @Config(
            particleNum: 50
            lifeSpan: 1000
            startWidth: 4
            startHeight: 4
            endWidth: 1
            endHeight: 1
            startColor: new UnpColor(225, 225, 50, 0.8)
            endColor: new UnpColor(115, 0, 0, 0.5)
            totalTime: 200
        )

    initializeParticle: (currParticle) ->
        _randomAngle = Math.PI * 2 * Math.random()
        _explosionSpeed = 50 * (0.5 + Math.random())

        currParticle.speedX = Math.cos(_randomAngle) * _explosionSpeed
        currParticle.speedY = Math.sin(_randomAngle) * _explosionSpeed

    updateParticle: (currParticle) ->


class UnpVisualFx.Flame extends UnpVisualFx.ParticleEffect
    constructor: (targetCanvas) ->
        super(targetCanvas, 'Flame')
        @Config(
            particleNum: 25,
            lifeSpan: 1000,
            startWidth: 12,
            startHeight: 12,
            endWidth: 8,
            endHeight: 8,
            startColor: new UnpColor(250, 225, 50, 0.8),
            endColor: new UnpColor(115, 0, 0, 0.5),
            texture: 'RadialFade'
        )

    initializeParticle: (currParticle) ->
        console.log
        _explosionSpeed = 40
        _flameAccelY = -120

        _randomAngle = Math.PI * 2 * Math.random()
        _randomSpeed = _explosionSpeed * Math.random()

        currParticle.speedX = Math.cos(_randomAngle) * _randomSpeed
        currParticle.speedY = Math.sin(_randomAngle) * _randomSpeed

        currParticle.accelY = _flameAccelY
        currParticle.accelX = - (currParticle.speedX * 2)

    updateParticle: (currParticle) ->



class UnpVisualFx.Swirl extends UnpVisualFx.ParticleEffect
    constructor: (targetCanvas) ->
        super(targetCanvas, 'Swirl')
        @Config(
            particleNum: 30,
            lifeSpan: 1000,
            startWidth: 4,
            startHeight: 4,
            endWidth: 1,
            endHeight: 1,
            startColor: new UnpColor(0, 225, 0, 0.8),
            endColor: new UnpColor(0, 0, 0, 0.5)
        )

    initializeParticle: (currParticle) ->
        console.log
        _timedAngle = ((new Date().getTime() % 1000) / 1000) * Math.PI * 2
        _particleSpeed = 30

        currParticle.speedX = Math.cos(_timedAngle) * _particleSpeed
        currParticle.speedY = Math.sin(_timedAngle) * _particleSpeed

    updateParticle: (currParticle) ->




class UnpVisualFx.Spiral extends UnpVisualFx.ParticleEffect
    constructor: (targetCanvas) ->
        super(targetCanvas, 'Spiral')
        @Config(
            particleNum: 50,
            lifeSpan: 1000,
            startWidth: 2,
            startHeight: 2,
            endWidth: 1,
            endHeight: 1,
            startColor: new UnpColor(150, 0, 225, 0.8),
            endColor: new UnpColor(255, 255, 255, 0)
        )

        @_nextArm = 0;
        @_armNum = 3;

    initializeParticle: (currParticle) ->
        console.log
        _timedAngle = ((new Date().getTime() % 1000) / 1000) * Math.PI * 2
        _particleSpeed = 30

        _armAngle = ((Math.PI * 2) / @_armNum) * @_nextArm

        currParticle.speedX = Math.cos(_timedAngle + _armAngle) * _particleSpeed
        currParticle.speedY = Math.sin(_timedAngle + _armAngle) * _particleSpeed

        @_nextArm++
        @_nextArm = @_nextArm % @_armNum

    updateParticle: (currParticle) ->



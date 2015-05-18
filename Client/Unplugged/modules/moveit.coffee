class window.UnpMoveIt extends window.UnpModule
    constructor: (htmlCont) ->
        super('unpmoveit')

        @_isStarted = false
        @_moveItData = {}
        @_fireData = []
        @_boomData = []
        
        @moveDisplay = document.createElement('div')

        $(@moveDisplay)
            .addClass('unpmoveit-cont')
            .html('<div class="unpmoveit-display"><canvas></canvas></div>')
        
        @_displayCanvas = $(@moveDisplay).find('.unpmoveit-display canvas')[0]

        self = @

        $(@moveDisplay).find('.unpmoveit-display')
            .bind 'click', (evtObj) ->
                _clickPosX = evtObj.clientX
                _clickPosY = evtObj.clientY

                self.moveTo(_clickPosX - (this.offsetWidth / 2), _clickPosY - (this.offsetHeight / 2))


        $(@moveDisplay).find('.unpmoveit-display')
            .bind 'contextmenu', (evtObj) ->
                evtObj.preventDefault()

                _clickPosX = evtObj.clientX
                _clickPosY = evtObj.clientY

                self.fireTo(_clickPosX - (this.offsetWidth / 2), _clickPosY - (this.offsetHeight / 2))

        $(htmlCont).append(@moveDisplay)
        


        loopCallback = () ->
            if(self._isStarted is true)
                _cContext = self._displayCanvas.getContext("2d")

                _baseAccel = self._baseCostants.baseaccel
                _maxSpeed = self._baseCostants.maxspeed
                _brakePower = self._baseCostants.brakepower

                _fireLifeSpan = self._baseCostants.firelifespan
                _boomLifeSpan = self._baseCostants.boomlifespan

                _nowTime = new Date().getTime()

                # update
                _fireToRemove = []

                for _fData in self._fireData
                    if(_nowTime - _fData.creationTime > _fireLifeSpan)
                        _fireToRemove.push(_fData)
                    else
                        _updateTimeDiff = (_nowTime - _fData.lastUpdate) / 1000

                        _fData.fireX += _fData.fireSpeedX * _updateTimeDiff
                        _fData.fireY += _fData.fireSpeedY * _updateTimeDiff

                        _fData.lastUpdate = _nowTime


                for _cRemoveObject in _fireToRemove
    #                for(i = 0 i < _fireToRemove.length i++)
#                    _cRemoveObject = _fireToRemove[i]
                    _bData = {}
                    _bData.boomX = 	_cRemoveObject.fireX
                    _bData.boomY = 	_cRemoveObject.fireY
                    _bData.creationTime = _nowTime
                    self._boomData.push(_bData)

                    for j in [0..self._fireData.length ]
                        if(self._fireData[j] == _cRemoveObject)
                            self._fireData[j] = null
                            self._fireData.splice(j, 1)
                            break

                _boomToRemove = []

                for _bData in self._boomData
                    if(_nowTime - _bData.creationTime > _boomLifeSpan)
                        _boomToRemove.push(_bData)

                for _cRemoveObject in _boomToRemove

                    for j in [0..self._boomData.length]
                        if self._boomData[j] is _cRemoveObject
                            self._boomData[j] = null
                            self._boomData.splice(j, 1)
                            break



                console.log

                for _ckey of self._moveItData
                    console.log

                    _cData = self._moveItData[_ckey]
                    _updateTimeDiff = (_nowTime - _cData.lastUpdate) / 1000

                    _diffX = -(_cData.x - _cData.goToX)
                    _diffY = -(_cData.y - _cData.goToY)

                    if (Math.abs(_diffX) < 0.5) && (Math.abs(_diffY) < 0.5)
                        _diffY = 0
                        _cData.y = _cData.goToY
                        _cData.speedY = 0
                        _diffX = 0
                        _cData.x = _cData.goToX
                        _cData.speedX = 0
                        _cData.animationTime = null


                    _diffModule = Math.sqrt(Math.pow(_diffX, 2) + Math.pow(_diffY, 2))

                    if (_diffX != 0)

                        _diffXRatio = _diffX / _diffModule
                        _accelX = _baseAccel * _diffXRatio

                        if(Math.abs(_cData.speedX) / _brakePower > Math.abs(_diffX))
                            _accelX = -_cData.speedX * _brakePower

                        _cData.speedX += (_accelX * _updateTimeDiff)


                    if (_diffY != 0)

                        _diffYRatio = _diffY / _diffModule
                        _accelY = _baseAccel * _diffYRatio

                        if(Math.abs(_cData.speedY) / _brakePower > Math.abs(_diffY))
                            _accelY = -_cData.speedY * _brakePower

                        _cData.speedY += (_accelY * _updateTimeDiff)


                    _speedModule = Math.sqrt(Math.pow(_cData.speedX, 2) + Math.pow(_cData.speedY, 2))

                    if(_speedModule > _maxSpeed)

                        _cData.speedX = _maxSpeed * _cData.speedX / _speedModule
                        _cData.speedY = _maxSpeed * _cData.speedY / _speedModule


                    _cData.x += (_cData.speedX * _updateTimeDiff)
                    _cData.y += (_cData.speedY * _updateTimeDiff)

                    _cData.lastUpdate = _nowTime


                # draw
                _circleRadius = self._baseCostants.circleradius
                _fireRadius = self._baseCostants.fireradius
                _boomSize = self._baseCostants.boomsize

                _animateRadiusTime = 1000
                _fontSize = 12
                _HPBarWidth = 24

                _centerX = self._displayCanvas.offsetWidth / 2
                _centerY = self._displayCanvas.offsetHeight / 2

                _cContext.clearRect(0, 0 , self._displayCanvas.offsetWidth, self._displayCanvas.offsetHeight)
                _cContext.lineWidth = 1

                for _bData in self._boomData.length

                    _finalX = _centerX + parseInt(_bData.boomX, 10)
                    _finalY = _centerY + parseInt(_bData.boomY, 10)

                    _boomColorProg = (_boomLifeSpan - (_nowTime - _bData.creationTime)) / _boomLifeSpan
                    _boomColorLight = Math.round(255 * (1 - _boomColorProg))
                    _boomColor = 'rgba(' + _boomColorLight + ',' + _boomColorLight + ',255,' + _boomColorProg + ')'

                    _cContext.strokeStyle = _boomColor
                    _cContext.fillStyle = _boomColor

                    _cContext.beginPath()
                    _cContext.moveTo(_finalX, _finalY)

                    _randomAngle = Math.random() * Math.PI * 2
                    _cContext.moveTo(_finalX + Math.cos(_randomAngle - 0.5) * _boomSize, _finalY + Math.sin(_randomAngle - 0.5) * _boomSize)

                    for j in [0..3]
                        _randomAngle = Math.random() * Math.PI * 2
                        _cContext.lineTo(_finalX + Math.cos(_randomAngle - 0.5) * _boomSize, _finalY + Math.sin(_randomAngle - 0.5) * _boomSize)

                    _cContext.stroke()
                    _cContext.closePath()


                for _fData in self._fireData

                    _finalX = _centerX + parseInt(_fData.fireX, 10)
                    _finalY = _centerY + parseInt(_fData.fireY, 10)

                    _cContext.strokeStyle = '#ffffff'
                    _cContext.fillStyle = '#ffffff'

                    _cContext.beginPath()
                    _cContext.arc(_finalX, _finalY, _fireRadius, 0, Math.PI * 2,true)
                    _cContext.fill()
                    _cContext.closePath()



                for _ckey of self._moveItData
                    console.log
                    _cData = self._moveItData[_ckey]

                    _finalX = _centerX + parseInt(_cData.x, 10)
                    _finalY = _centerY + parseInt(_cData.y, 10)

                    _finalgoToX = _centerX + parseInt(_cData.goToX, 10)
                    _finalgoToY = _centerY + parseInt(_cData.goToY, 10)

                    _cContext.strokeStyle = '#ffffff'
                    _cContext.fillStyle = '#ffffff'
                    _cContext.textAlign = 'center'
                    _cContext.font = _fontSize + "px verdana"
                    _cContext.fillText(_cData.name, _finalX, _finalY + _circleRadius + _fontSize)

                    _effectiveHPBarWidth = _HPBarWidth * _cData.hp / 100
                    _cContext.fillRect(_finalX - _effectiveHPBarWidth / 2, _finalY - (_circleRadius + _fontSize), _effectiveHPBarWidth, _fontSize / 2)

                    if(_cData.dead)
                        _cContext.strokeStyle = 'rgba(100, 100, 100, 0.5)'
                        _cContext.fillStyle = 'rgba(100, 100, 100, 0.5)'

                    else
                        _cContext.strokeStyle = _cData.color
                        _cContext.fillStyle = _cData.color


                    _cContext.beginPath()
                    _cContext.arc(_finalgoToX, _finalgoToY, _circleRadius / 5, 0, Math.PI * 2,true)
                    _cContext.fill()
                    _cContext.closePath()

                    _animateRadius = 0

                    if _cData.animationTime
                        _animateRadiusMod = ((_nowTime - _cData.animationTime) % _animateRadiusTime) / _animateRadiusTime
                        _animateRadiusFact = 0

                        if(_animateRadiusMod < 0.25)
                            _animateRadiusFact = - _animateRadiusMod

                        else if (_animateRadiusMod < 0.75)
                            _animateRadiusFact = - 0.5 + _animateRadiusMod

                        else
                            _animateRadiusFact = 1 - _animateRadiusMod

                        _animateRadiusMod += 0.25
                        _animateRadius = _circleRadius * 0.8 * _animateRadiusFact


                    _cContext.beginPath()
                    _cContext.lineWidth = _circleRadius / 2
                    _cContext.arc(_finalX, _finalY, _circleRadius + _animateRadius, 0, Math.PI * 2,true)
                    _cContext.stroke()
                    _cContext.closePath()


                # test stuff

                if window._testVisualFx # isnt null

                    $(window._testVisualFx).each () ->
                        console.log ''
                        switch self.effectName
                            when 'StripeArray', 'BezierArray', 'LineArray', 'TimedBezier'
                                self.configObject.startX = self._displayCanvas.offsetWidth - _finalX
                                self.configObject.startY = self._displayCanvas.offsetHeight - _finalY
                                self.configObject.endX = _finalX
                                self.configObject.endY = _finalY

                            when 'Explosion', 'Flame', 'Swirl', 'Spiral'
                                self.configObject.posX = self._displayCanvas.offsetWidth - _finalX
                                self.configObject.posY = self._displayCanvas.offsetHeight - _finalY


                        console.log ''
                        this.Draw()

        window.setInterval (() -> self._loopCallback(self)), UnpUtils.getRefreshRate()


    _loopCallback: (self) ->
        if(self._isStarted is true)
            _cContext = self._displayCanvas.getContext("2d")

            _baseAccel = self._baseCostants.baseaccel
            _maxSpeed = self._baseCostants.maxspeed
            _brakePower = self._baseCostants.brakepower

            _fireLifeSpan = self._baseCostants.firelifespan
            _boomLifeSpan = self._baseCostants.boomlifespan

            _nowTime = new Date().getTime()

            # update
            _fireToRemove = []

            for _fData in self._fireData
                if(_nowTime - _fData.creationTime > _fireLifeSpan)
                    _fireToRemove.push(_fData)
                else
                    _updateTimeDiff = (_nowTime - _fData.lastUpdate) / 1000

                    _fData.fireX += _fData.fireSpeedX * _updateTimeDiff
                    _fData.fireY += _fData.fireSpeedY * _updateTimeDiff

                    _fData.lastUpdate = _nowTime


            for _cRemoveObject in _fireToRemove
                #                for(i = 0 i < _fireToRemove.length i++)
#                    _cRemoveObject = _fireToRemove[i]
                _bData = {}
                _bData.boomX = 	_cRemoveObject.fireX
                _bData.boomY = 	_cRemoveObject.fireY
                _bData.creationTime = _nowTime
                self._boomData.push(_bData)

                for j in [0..self._fireData.length ]
                    if(self._fireData[j] == _cRemoveObject)
                        self._fireData[j] = null
                        self._fireData.splice(j, 1)
                        break

            _boomToRemove = []

            for _bData in self._boomData
                if(_nowTime - _bData.creationTime > _boomLifeSpan)
                    _boomToRemove.push(_bData)

            for _cRemoveObject in _boomToRemove

                for j in [0..self._boomData.length]
                    if self._boomData[j] is _cRemoveObject
                        self._boomData[j] = null
                        self._boomData.splice(j, 1)
                        break



            console.log

            for _ckey of self._moveItData
                console.log

                _cData = self._moveItData[_ckey]
                _updateTimeDiff = (_nowTime - _cData.lastUpdate) / 1000

                _diffX = -(_cData.x - _cData.goToX)
                _diffY = -(_cData.y - _cData.goToY)

                if (Math.abs(_diffX) < 0.5) && (Math.abs(_diffY) < 0.5)
                    _diffY = 0
                    _cData.y = _cData.goToY
                    _cData.speedY = 0
                    _diffX = 0
                    _cData.x = _cData.goToX
                    _cData.speedX = 0
                    _cData.animationTime = null


                _diffModule = Math.sqrt(Math.pow(_diffX, 2) + Math.pow(_diffY, 2))

                if (_diffX != 0)

                    _diffXRatio = _diffX / _diffModule
                    _accelX = _baseAccel * _diffXRatio

                    if(Math.abs(_cData.speedX) / _brakePower > Math.abs(_diffX))
                        _accelX = -_cData.speedX * _brakePower

                    _cData.speedX += (_accelX * _updateTimeDiff)


                if (_diffY != 0)

                    _diffYRatio = _diffY / _diffModule
                    _accelY = _baseAccel * _diffYRatio

                    if(Math.abs(_cData.speedY) / _brakePower > Math.abs(_diffY))
                        _accelY = -_cData.speedY * _brakePower

                    _cData.speedY += (_accelY * _updateTimeDiff)


                _speedModule = Math.sqrt(Math.pow(_cData.speedX, 2) + Math.pow(_cData.speedY, 2))

                if(_speedModule > _maxSpeed)

                    _cData.speedX = _maxSpeed * _cData.speedX / _speedModule
                    _cData.speedY = _maxSpeed * _cData.speedY / _speedModule


                _cData.x += (_cData.speedX * _updateTimeDiff)
                _cData.y += (_cData.speedY * _updateTimeDiff)

                _cData.lastUpdate = _nowTime


            # draw
            _circleRadius = self._baseCostants.circleradius
            _fireRadius = self._baseCostants.fireradius
            _boomSize = self._baseCostants.boomsize

            _animateRadiusTime = 1000
            _fontSize = 12
            _HPBarWidth = 24

            _centerX = self._displayCanvas.offsetWidth / 2
            _centerY = self._displayCanvas.offsetHeight / 2

            _cContext.clearRect(0, 0 , self._displayCanvas.offsetWidth, self._displayCanvas.offsetHeight)
            _cContext.lineWidth = 1

            for _bData in self._boomData.length

                _finalX = _centerX + parseInt(_bData.boomX, 10)
                _finalY = _centerY + parseInt(_bData.boomY, 10)

                _boomColorProg = (_boomLifeSpan - (_nowTime - _bData.creationTime)) / _boomLifeSpan
                _boomColorLight = Math.round(255 * (1 - _boomColorProg))
                _boomColor = 'rgba(' + _boomColorLight + ',' + _boomColorLight + ',255,' + _boomColorProg + ')'

                _cContext.strokeStyle = _boomColor
                _cContext.fillStyle = _boomColor

                _cContext.beginPath()
                _cContext.moveTo(_finalX, _finalY)

                _randomAngle = Math.random() * Math.PI * 2
                _cContext.moveTo(_finalX + Math.cos(_randomAngle - 0.5) * _boomSize, _finalY + Math.sin(_randomAngle - 0.5) * _boomSize)

                for j in [0..3]
                    _randomAngle = Math.random() * Math.PI * 2
                    _cContext.lineTo(_finalX + Math.cos(_randomAngle - 0.5) * _boomSize, _finalY + Math.sin(_randomAngle - 0.5) * _boomSize)

                _cContext.stroke()
                _cContext.closePath()


            for _fData in self._fireData

                _finalX = _centerX + parseInt(_fData.fireX, 10)
                _finalY = _centerY + parseInt(_fData.fireY, 10)

                _cContext.strokeStyle = '#ffffff'
                _cContext.fillStyle = '#ffffff'

                _cContext.beginPath()
                _cContext.arc(_finalX, _finalY, _fireRadius, 0, Math.PI * 2,true)
                _cContext.fill()
                _cContext.closePath()



            for _ckey of self._moveItData
                console.log
                _cData = self._moveItData[_ckey]

                _finalX = _centerX + parseInt(_cData.x, 10)
                _finalY = _centerY + parseInt(_cData.y, 10)

                _finalgoToX = _centerX + parseInt(_cData.goToX, 10)
                _finalgoToY = _centerY + parseInt(_cData.goToY, 10)

                _cContext.strokeStyle = '#ffffff'
                _cContext.fillStyle = '#ffffff'
                _cContext.textAlign = 'center'
                _cContext.font = _fontSize + "px verdana"
                _cContext.fillText(_cData.name, _finalX, _finalY + _circleRadius + _fontSize)

                _effectiveHPBarWidth = _HPBarWidth * _cData.hp / 100
                _cContext.fillRect(_finalX - _effectiveHPBarWidth / 2, _finalY - (_circleRadius + _fontSize), _effectiveHPBarWidth, _fontSize / 2)

                if(_cData.dead)
                    _cContext.strokeStyle = 'rgba(100, 100, 100, 0.5)'
                    _cContext.fillStyle = 'rgba(100, 100, 100, 0.5)'

                else
                    _cContext.strokeStyle = _cData.color
                    _cContext.fillStyle = _cData.color


                _cContext.beginPath()
                _cContext.arc(_finalgoToX, _finalgoToY, _circleRadius / 5, 0, Math.PI * 2,true)
                _cContext.fill()
                _cContext.closePath()

                _animateRadius = 0

                if _cData.animationTime
                    _animateRadiusMod = ((_nowTime - _cData.animationTime) % _animateRadiusTime) / _animateRadiusTime
                    _animateRadiusFact = 0

                    if(_animateRadiusMod < 0.25)
                        _animateRadiusFact = - _animateRadiusMod

                    else if (_animateRadiusMod < 0.75)
                        _animateRadiusFact = - 0.5 + _animateRadiusMod

                    else
                        _animateRadiusFact = 1 - _animateRadiusMod

                    _animateRadiusMod += 0.25
                    _animateRadius = _circleRadius * 0.8 * _animateRadiusFact


                _cContext.beginPath()
                _cContext.lineWidth = _circleRadius / 2
                _cContext.arc(_finalX, _finalY, _circleRadius + _animateRadius, 0, Math.PI * 2,true)
                _cContext.stroke()
                _cContext.closePath()


            # test stuff

            if window._testVisualFx # isnt null

                $(window._testVisualFx).each () ->
                    console.log
                    switch this.effectName
                        when 'StripeArray', 'BezierArray', 'LineArray', 'TimedBezier'
                            this.configObject.startX = self._displayCanvas.offsetWidth - _finalX
                            this.configObject.startY = self._displayCanvas.offsetHeight - _finalY
                            this.configObject.endX = _finalX
                            this.configObject.endY = _finalY

                        when 'Explosion', 'Flame', 'Swirl', 'Spiral'
                            this.configObject.posX = self._displayCanvas.offsetWidth - _finalX
                            this.configObject.posY = self._displayCanvas.offsetHeight - _finalY


                    console.log
                    this.Draw()

    handleAction: (actionName, actionData) ->
        console.log
        switch actionName
            when 'init'
                $(@moveDisplay).addClass('unpmoveit-started')
                @_isStarted = true
                _UnpMoveToResize()
                @_baseCostants = actionData

            when 'add'
                _cData = {}
                _cData.color = actionData.color
                _cData.name = actionData.name
                _cData.x = parseInt(actionData.x, 10)
                _cData.y = parseInt(actionData.y, 10)
                _cData.goToX = parseInt(actionData.x, 10)
                _cData.goToY = parseInt(actionData.y, 10)
                _cData.speedX = 0
                _cData.speedY = 0
                _cData.hp = parseInt(actionData.hp, 10)
                _cData.dead = (actionData.dead.toLowerCase() is 'true')
                _cData.lastUpdate = new Date().getTime()

                @_moveItData[actionData['id']] = _cData

            when 'move'
                _cData = @_moveItData[actionData['id']]

                _cData.goToX = parseInt(actionData['x'], 10)
                _cData.goToY = parseInt(actionData['y'], 10)
                if _cData.animationTime
                    _cData.animationTime = new Date().getTime()

            when 'sethp'

                _cData = @_moveItData[actionData['id']]

                _cData.hp = parseInt(actionData.hp, 10)
                _cData.dead = (actionData.dead.toLowerCase() is 'true')


            when 'fire'
                console.log

                _cData = @_moveItData[actionData['id']]

                _fireSpeed = @_baseCostants.firespeed #25
                _fireStartDist = @_baseCostants.firestartdist #20

                _fData = {}

                _fData.fireX = parseInt(_cData.x, 10)
                _fData.fireY = parseInt(_cData.y, 10)
                _fData.fireToX = parseInt(actionData['x'], 10)
                _fData.fireToY = parseInt(actionData['y'], 10)
                _fData.creationTime = new Date().getTime()
                _fData.lastUpdate = _fData.creationTime

                _diffX = -(_fData.fireX - _fData.fireToX)
                _diffY = -(_fData.fireY - _fData.fireToY)

                _diffModule = Math.sqrt(Math.pow(_diffX, 2) + Math.pow(_diffY, 2))

                _fData.fireSpeedX = _fireSpeed * _diffX / _diffModule
                _fData.fireSpeedY = _fireSpeed * _diffY / _diffModule

                _fData.fireX += _fireStartDist * _diffX / _diffModule
                _fData.fireY += _fireStartDist * _diffY / _diffModule

                @_fireData.push(_fData)

            when 'del'
                @_moveItData[actionData['id']] = null
                delete @_moveItData[actionData['id']]


    moveTo: (xPos, yPos) ->
        _umpMsg = new UnpMessage()
        _umpMsg.addAction(this.modName, 'move',  'x': Math.round(xPos), 'y': Math.round(yPos) )
        _umpMsg.send()

    fireTo: (xPos, yPos) ->
        _umpMsg = new UnpMessage()
        _umpMsg.addAction(this.modName, 'fire',  'x': Math.round(xPos), 'y': Math.round(yPos) )
        _umpMsg.send()




window._UnpMoveToResize = ->
    $('.unpmoveit-display canvas').each  () ->
        $(this).attr('width', this.parentElement.offsetWidth)
        $(this).attr('height', this.parentElement.offsetHeight)
        this.getContext("2d").clearRect(0, 0, this.offsetWidth, this.offsetHeight)

$(window).bind('resize', window._UnpMoveToResize)



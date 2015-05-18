class window.UnpModule
    constructor: (@modName) ->
        console.log @modName
        window.ModuleList[@modName] = @


    handleAction: (actionName, actionData) ->


class window.UnpMessage
    constructor: ->
        @actionList = []

    addAction: (modName, actionName, actionData) ->
        @actionList.push
            'module': modName
            'action': actionName
            'data': actionData

    send: ->
        msg = {}
        msg.unp = @actionList
        window.BaseWebSocket.send(JSON.stringify(msg))

class window.UnpInit
    constructor: ->
        UnpWarning.LoadingSplashShow()
        $('body').addClass 'unp-connection-closed'

        window.ModuleList = {}
        window.BaseWebSocket = new WebSocket(window.ServerUrl)
        _socketOpen = false;

        window.BaseWebSocket.onopen = ()->
            console.log ''
            UnpWarning.LoadingSplashHide()
            console.log 'Connection to ' + window.ServerUrl + ' is open'
            _socketOpen = true
            $('body')
            .addClass 'unp-connection-open'
            .removeClass 'unp-connection-closed'

        window.BaseWebSocket.onerror = (evt) ->
            console.log "Error"

        window.BaseWebSocket.onmessage = (evt) ->
            _recMessage = evt.data
            console.log "Message received: " + _recMessage
            _objMessage = $.parseJSON _recMessage
            _cUnpMessage = new UnpMessage()

            #      for(var i = 0; i < _objMessage.unp.length; i++)
            for _cAction in _objMessage.unp
                module = window.ModuleList[_cAction.module]
                module.handleAction(_cAction.action, _cAction.data)

        window.BaseWebSocket.onclose = () ->
            console.log('Connection to ' + window.ServerUrl + ' is closed')
            $('body')
            .removeClass 'unp-connection-open'
            .addClass 'unp-connection-closed'

            if !_socketOpen
                UnpWarning.LoadingSplashHide()

            _socketOpen = false

            UnpWarning.Alert 'Connection to server failed. Press "OK" to try again.',
                () -> document.location.reload()

        window.BaseWebSocket._sendBASE = window.BaseWebSocket.send

        window.BaseWebSocket.send = (sendMessage)->
            console.log 'Sending message: ' + sendMessage
            window.BaseWebSocket._sendBASE(sendMessage)


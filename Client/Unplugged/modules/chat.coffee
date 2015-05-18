class window.UnpChat extends window.UnpModule
    constructor: (htmlCont) ->
        console.log

        super('unpchat')
        self = @

        @chatDisplay = document.createElement('div')
        $(@chatDisplay).addClass('unpchat-cont').html(
                '<div class="unpchat-message-log"></div>' +
                '<div class="unpchat-message-input"><input type="text"/></div>')

        $(@chatDisplay).find('.unpchat-message-input input')
            .bind 'keyup', (evtObj) ->
                console.log
                if(evtObj.keyCode == 13)
                    console.log
                    self.chatInput(this.value)
                    $(this).val('')

        $(htmlCont).append(@chatDisplay)

        @handleAction = (actionName, actionData) ->
            console.log
            switch actionName

                when 'message'
                    _msgLog = $(@chatDisplay).find('.unpchat-message-log')[0]

                    _cMsgElem = document.createElement('div')
                    _msgColor = actionData.color

                    $(_cMsgElem).addClass('unpchat-message').css('color', _msgColor).html(
                            '<div class="unpchat-from">' + actionData.from + '</div>' +
                            '<div class="unpchat-to">' + actionData.to + '</div>' +
                            '<div class="unpchat-text">' + actionData.text + '</div>')

                    $(_msgLog).append(_cMsgElem)
                    _msgLog.scrollTop = _msgLog.scrollHeight

                when 'sysmsg'
                    _msgLog = $(@chatDisplay).find('.unpchat-message-log')[0]

                    _cMsgElem = document.createElement('div')
                    _msgColor = actionData.color

                    $(_cMsgElem).addClass('unpchat-message')
                        .css 'color', _msgColor
                        .addClass('unpchat-sysmsg').html(
                            '<div class="unpchat-text">' + actionData.text + '</div>' +
                            '</div>')

                    $(_msgLog).append(_cMsgElem)
                    _msgLog.scrollTop = _msgLog.scrollHeight

        @chatInput = (textVal) ->
            console.log
            _umpMsg = new UnpMessage()
            _umpMsg.addAction(this.modName, 'message',  'to': 'all', 'text': textVal )
            _umpMsg.send()



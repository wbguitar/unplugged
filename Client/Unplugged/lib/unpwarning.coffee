UnpUtils._LoadingSplashCount = 0

class window.UnpWarning
    @constructor:() ->

    @WarningSet: (warningText, buttonData) ->

        console.log
        $('#unp-warning-text').html warningText
        $('#unp-warning-splash').show()
        _buttonDiv = $('#unp-warning-buttons').first()
        $(_buttonDiv).html ''

        $(buttonData).each ()->
            console.log
            _cButton = document.createElement 'div'
            _clickFunction = this.click
            $(_cButton).addClass 'unp-warning-button'
                .html(this.text)
                .bind 'click', () ->
                    UnpWarning.WarningHide()
                    if (_clickFunction != null)
                        _clickFunction

        UnpWarning.WarningShow()

    @Alert: (alertText, onButtonOk) ->
        console.log
        buttonData = [
            'text': 'OK'
            'click': onButtonOk
        ]

        UnpWarning.WarningSet(alertText, buttonData)

    @Confirm: (confirmText, onButtonOk, onButtonCancel) ->
        console.log
        UnpWarning.WarningSet(confirmText, [ { 'text': 'OK', 'click': onButtonOk }, { 'text': 'Cancel', 'click': onButtonCancel } ])

    @WarningShow: ->
        console.log
        $('#unp-warning-splash').show

    @WarningHide: ->
        console.log
        $('#unp-warning-splash').hide

    @LoadingSplashShow: ->
        console.log
        UnpUtils._LoadingSplashCount++
        if UnpUtils._LoadingSplashCount > 0
            $('#unp-loading-splash').show()

    @LoadingSplashHide: ->
        console.log
        UnpUtils._LoadingSplashCount--;
        if UnpUtils._LoadingSplashCount <= 0
            UnpUtils._LoadingSplashCount = 0
            $('#unp-loading-splash').hide()

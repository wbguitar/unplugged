class window.UnpAuth extends window.UnpModule
    constructor: (htmlCont) ->
        super('unpauth')
        @authDisplay = document.createElement('div')
        self = @

        $(@authDisplay).addClass('unpauth-cont').html(
                '<div class="unpauth-login-desc">Login</div>' +
                '<div class="unpauth-login-input"><input type="text"/></div>' +
                '<div class="unpauth-logout">Logout</div>')

        $(@authDisplay).find('.unpauth-login-input input')
            .bind 'keyup', (evtObj) ->
                if(evtObj.keyCode == 13)
                    console.log this.value
                    self.authLogin(this.value)
                    $(this).val('')

        $(@authDisplay).find('.unpauth-logout')
            .bind 'click',
                (evtObj) ->
                    console.log
                    self.authLogout(this.value)

        $(htmlCont).append(@authDisplay)

    handleAction: (actionName, actionData) ->
        console.log
        switch actionName
            when 'login-result'
                UnpWarning.LoadingSplashHide()
                if actionData['status'] is 'ok'
                    $(@authDisplay).parent().addClass('unpauth-login-ok')
            when 'logout-result'
                UnpWarning.LoadingSplashHide()
                if actionData['status'] is 'ok'
                    document.location.reload()

    authLogin: (textVal) ->
        console.log
        UnpWarning.LoadingSplashShow()
        _umpMsg = new UnpMessage()
        _umpMsg.addAction(@modName, 'login',  'username': textVal )
        _umpMsg.send()

    authLogout: (textVal) ->
        console.log
        UnpWarning.LoadingSplashShow()
        _umpMsg = new UnpMessage()
        _umpMsg.addAction(@modName, 'logout', { })
        _umpMsg.send()




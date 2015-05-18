class window.UnpToolbar
    @_UnpToolbarOpen: (targetElement) ->
        $(targetElement).parent().find('.unptoolbar-button-menu-open').removeClass('unptoolbar-button-menu-open')
        $(targetElement).addClass('unptoolbar-button-menu-open')

    @_UnpToolbarClose: (targetElement) ->
        $(targetElement).removeClass('unptoolbar-button-menu-open')

    @_UnpToolbarToggle: (targetElement) ->
        if $(targetElement).hasClass('unptoolbar-button-menu-open') is true
            @_UnpToolbarClose(targetElement)
        else
            @_UnpToolbarOpen(targetElement)

    constructor: (htmlCont, menuData) ->
        console.log
        _contDiv = document.createElement 'div'
        $(_contDiv).addClass 'unptoolbar-cont'
            .addClass 'unptoolbar-cont-closed'

        _isWellOutTimer = null

        $(_contDiv).on 'mouseover', ->
            $(_contDiv).removeClass('unptoolbar-cont-closed')

            if _isWellOutTimer
                window.clearTimeout _isWellOutTimer
                _isWellOutTimer = null;

        $(_contDiv).bind 'mouseout', ->
            if _isWellOutTimer isnt null
                window.clearTimeout _isWellOutTimer

            callback = ->
                console.log
                $(_contDiv).addClass('unptoolbar-cont-closed')

            _isWellOutTimer = window.setTimeout callback, 500

#        $(menuData).each (i, el) -> #forse va usato =>
#            console.log
#            _cButton = document.createElement 'div'
#            $(_cButton).addClass('unptoolbar-button').html('<span class="unptoolbar-button-text">' + el.text + '</span>')
#
#            if el.click isnt null
#                $(_cButton).bind 'click', el.click
#
#            if el.menu isnt null
#                _cMenuCont = document.createElement 'div'
#                $(_cMenuCont).addClass 'unptoolbar-button-menu'
#
#                $(el.menu).each ->
#                    _cMenuElement = document.createElement('div')
#
#                    $(_cMenuElement).html('<span>' + el.text + '</span>')
#                    $(_cMenuElement).addClass('unptoolbar-button-menu-element')
#
#                    if el.click isnt null
#                        $(_cMenuElement).bind 'click', el.click
#
#                    $(_cMenuCont).append _cMenuElement
#
#                $(_cButton).bind 'mouseover', ->
#                    @_UnpToolbarOpen(el)
#
#                $(_cButton).bind 'mouseout', ->
#                    @_UnpToolbarClose(el)
#
#                $(_cButton).append(_cMenuCont)
#
#            $(_contDiv).append(_cButton)


        $(menuData).each( () ->
            console.log

            _cButton = document.createElement('div')
            $(_cButton).addClass('unptoolbar-button').html('<span class="unptoolbar-button-text">' + this.text + '</span>')

            if(this.click)
                $(_cButton).bind('click', this.click)
            
            
            if this.menu #isnt null
            
                _cMenuCont = document.createElement('div')
                $(_cMenuCont).addClass('unptoolbar-button-menu')

                $(this.menu).each( () ->
                    _cMenuElement = document.createElement('div')

                    $(_cMenuElement).html('<span>' + this.text + '</span>')
                    $(_cMenuElement).addClass('unptoolbar-button-menu-element')

                    if this.click #isnt null
                        $(_cMenuElement).bind('click', this.click)

                    $(_cMenuCont).append(_cMenuElement))

                $(_cButton).bind('mouseover', () -> UnpToolbar._UnpToolbarOpen(this) )
                $(_cButton).bind('mouseout', () -> UnpToolbar._UnpToolbarClose(this) )

                $(_cButton).append(_cMenuCont)


            $(_contDiv).append(_cButton))

        $(htmlCont).append _contDiv
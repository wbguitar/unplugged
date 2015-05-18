class window.Init
    @start: ->
        new UnpClientInit();
    @test: ->
        _color1 = new UnpColor(120, 120, 120, 120)
        _color2 = new UnpColor(123, 213, 143, 200)
        menudata = [
            'text': 'boh'
            'click': -> alert 'mah'
        ]
        tCont = $('#unptoolbar-div')[0]
        toolbar = new window.UnpToolbar(tCont, menudata)
        console.log(toolbar)

        canvas = $('<canvas/>')[0]

        cfgObj =
            startX: 0
            startY: 0
            endX: 10
            endY: 10
            color1: _color1
            color2: _color2
            colorFrom: _color1
            colorTo: _color2
            lineColor: _color1
            stripeWidth: 10
            stripeNum: 10
            lineWidth: 2
            lineNum: 3
            maxDist: 100


        fx = new UnpVisualFx.StripeArray(canvas)
        fx.Config(cfgObj)
        fx.Draw()

        fx = new UnpVisualFx.BezierArray(canvas)
        fx.Config(cfgObj)
        fx.Draw()

        fx = new UnpVisualFx.LineArray(canvas)
        fx.Config(cfgObj)
        fx.Draw()

        fx = new UnpVisualFx.TimedBezier(canvas)
        fx.Config(cfgObj)
        fx.Draw()

        pelem = new UnpVisualFx.ParticleElement()

        fx = new UnpVisualFx.Explosion(canvas)
        fx.initializeParticle(pelem)
        fx.Draw()

        fx = new UnpVisualFx.Flame(canvas)
        fx.initializeParticle(pelem)
        fx.Draw()

        fx = new UnpVisualFx.Swirl(canvas)
        fx.initializeParticle(pelem)
        fx.Draw()

        fx = new UnpVisualFx.Spiral(canvas)
        fx.initializeParticle(pelem)
        fx.Draw()

        onok = ->
            console.log "ok"

        oncancel = ->
            console.log "cancel"

        UnpWarning.Alert("MAH", onok)
        UnpWarning.Confirm("MAH", onok, oncancel)

        window.ServerUrl = 'ws:\\\\' + UnpUtils.getQueryStringParam('server')

        cli = new UnpClientInit()

        console.log ''

$(document).ready ()->
    console.log
    Init.start()
Blink1Manager = require '../src/blink1-manager'

describe 'Blink1Manager', ->
  context 'blink1 over USB', ->
    beforeEach ->
      @blink1 =
        fadeToRGB: sinon.stub()
        close: sinon.stub()
      @sut = new Blink1Manager
      @sut.Blink1 = => @blink1

    describe '->turnOff', ->
      beforeEach (done) ->
        @sut.turnOff done

      it 'should call blink1.fadeToRGB', ->
        expect(@blink1.fadeToRGB).to.have.been.calledWith 0, 0, 0, 0

    describe '->turnOff', ->
      beforeEach (done) ->
        @sut.turnOff done

      it 'should call blink1.fadeToRGB', ->
        expect(@blink1.fadeToRGB).to.have.been.calledWith 0, 0, 0, 0

    describe '->updateColor', ->
      beforeEach (done) ->
        @sut.updateColor color: 'white', done

      it 'should call blink1.fadeToRGB', ->
        expect(@blink1.fadeToRGB).to.have.been.calledWith 0, 255, 255, 255

    context 'when USB fails', ->
      beforeEach (done) ->
        @sut.updateColorViaHttp = sinon.stub().yields null
        @blink1.fadeToRGB.throws new Error 'YIKES'
        @sut.updateColor color: 'white', done

      it 'should call the HTTP as a backup', ->
        expect(@sut.updateColorViaHttp).to.have.been.called

  context 'blink1 over HTTP', ->
    context 'when HTTP succeeds', ->
      beforeEach ->
        @request =
          get: sinon.stub().yields null, {}

        @sut = new Blink1Manager
        delete @sut.Blink1
        @sut.request = @request

      describe '->turnOff', ->
        beforeEach (done) ->
          @sut.turnOff done

        it 'should call request.get', ->
          expect(@request.get).to.have.been.calledWith 'http://127.0.0.1:8934/blink1/fadeToRGB', qs: rgb: '#000000'

      describe '->updateColor', ->
        beforeEach (done) ->
          @sut.updateColor color: 'white', done

        it 'should call request.get', ->
          expect(@request.get).to.have.been.calledWith 'http://127.0.0.1:8934/blink1/fadeToRGB', qs: rgb: '#ffffff'

    context 'when HTTP yields an error', ->
      beforeEach ->
        @request =
          get: sinon.stub().yields new Error 'something wrong'

        @sut = new Blink1Manager
        delete @sut.Blink1
        @sut.request = @request

      describe '->turnOff', ->
        beforeEach (done) ->
          @sut.turnOff (@error) =>
            done()

        it 'should yield an error', ->
          expect(@error).to.exist

    context 'when HTTP yields a bad statusCode', ->
      beforeEach ->
        @request =
          get: sinon.stub().yields null, statusCode: 500

        @sut = new Blink1Manager
        delete @sut.Blink1
        @sut.request = @request

      describe '->turnOff', ->
        beforeEach (done) ->
          @sut.turnOff (@error) =>
            done()

        it 'should yield an error', ->
          expect(@error).to.exist

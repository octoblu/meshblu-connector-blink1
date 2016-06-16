Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    {@blink1} = @sut
    @blink1.updateColor = sinon.stub().yields null
    @blink1.turnOff = sinon.stub().yields null
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->changeColor', ->
    beforeEach (done) ->
      color = 'white'
      @sut.changeColor {color}, done

    it 'should call blink1.updateColor', ->
      expect(@blink1.updateColor).to.have.been.calledWith color: 'white'

  describe '->turnOff', ->
    beforeEach (done) ->
      @sut.turnOff done

    it 'should call blink1.turnOff', ->
      expect(@blink1.turnOff).to.have.been.called

  describe '->onConfig', ->
    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig { type: 'hello' }).to.not.throw(Error)

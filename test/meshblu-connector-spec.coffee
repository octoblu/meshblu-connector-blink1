Blink1 = require '../'

describe 'Blink1', ->
  beforeEach ->
    @sut = new Blink1

  describe '->start', ->
    it 'should be a method', ->
      expect(@sut.start).to.be.a 'function'

    describe 'when called with nothing', ->
      it 'should throw an error', ->
        expect(@sut.start).to.throw(Error)

    describe 'when called with a device', ->
      it 'should not throw an error', ->
        expect(=> @sut.start({ uuid: 'hello' })).to.not.throw(Error)

  describe '->isOnline', ->
    it 'should be a method', ->
      expect(@sut.isOnline).to.be.a 'function'

    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->onMessage', ->
    it 'should be a method', ->
      expect(@sut.onMessage).to.be.a 'function'

    describe 'when called with a message', ->
      it 'should not throw an error', ->
        expect(=> @sut.onMessage({ topic: 'hello', devices: ['123'] })).to.not.throw(Error)

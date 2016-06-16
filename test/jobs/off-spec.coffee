{job} = require '../../jobs/off'

describe 'Off', ->
  context 'when given a valid message', ->
    beforeEach (done) ->
      @connector =
        turnOff: sinon.stub().yields null
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.turnOff', ->
      expect(@connector.turnOff).to.have.been.called

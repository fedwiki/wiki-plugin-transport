# build time tests for transport plugin
# see http://mochajs.org/

transport = require '../client/transport'
expect = require 'expect.js'

describe 'transport plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = transport.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'

// build time tests for transport plugin
// see http://mochajs.org/

import { transport } from '../src/client/transport.js'
import { describe, it } from 'node:test'
import expect from 'expect.js'

describe('transport plugin', () => {
  describe('expand', () => {
    it('can make itallic', () => {
      const result = transport.expand('hello *world*')
      expect(result).to.be('hello <i>world</i>')
    })
  })
})

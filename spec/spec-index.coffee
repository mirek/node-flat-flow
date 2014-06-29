
assert = require 'assert'
{ flow } = require '../src'

describe 'flow', ->

  it 'should invoke stuff', ->

    flow [

      (done) ->
        done null, { a: 1 }

      (done) ->
        done null, { b: 2 }

      -> false

      (done) ->
        done null, { c: 3 }

    ], (err) ->
      assert.ifError err
      assert.equal @a, 1
      assert.equal @b, 2
      assert.equal undefined, @c

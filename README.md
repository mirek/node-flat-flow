
## Summary

Async flow with conditional branching that looks good.

## Installation

    npm install flat-flow --save

## Usage

    { flow } = require 'flat-flow'

    flow [

      # After async call is finished, you pass result object.
      # Each attribute will be available as local, bound to this.
      (done) ->
        done null, { a: 1 }

      (done) ->
        done null, { b: 2 }

      # Arity 0 calls manage control flow. If false is returned
      # any following (non-arity 0) calls are skipped.
      -> false

      # This call is going to be skipped because of the conditional above.
      (done) ->
        done null, { c: 3 }

      # Also skipped.
      (done) ->
        done null, { d: -1 }

      # Another conditional, re-enables calls again.
      -> true

      # This will be called. All previously set locals are available, bound to this.
      (done) ->
        done null, { e: @a + @b }

    ], (err) ->
      assert.ifError err
      assert.equal @a, 1
      assert.equal @b, 2
      assert.equal @c, undefined
      assert.equal @d, undefined
      assert.equal @e, 3

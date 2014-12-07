
async = require 'async'
{ lshift } = require 'lshift'

# Merge locals.
merge = (a = {}, b = {}) ->
  for k, v of b
    if b.hasOwnProperty k
      a[ k ] = v
  a

# Async control flow.
#
# @param [Object] locals
# @param [Array<Function>] functions
# @param [Function] done
# @return [Flow]
flow = (locals, functions, done) ->

  [ locals, functions, done ] = lshift [
    [ locals, { $and: [ 'object', $not: 'array' ] }, {} ]
    [ functions, 'array', [] ]
    [ done, 'function', -> ]
  ]

  # Clone, hold this reference.
  locals = merge {}, locals

  # console.log { locals, functions, done }

  map = (f, r) ->
    switch

      # TODO: push/pop state
      when Array.isArray f
        # r.push (done) -> locals.pushState(...)
        f.forEach (g) ->
          map g, r
        # r.pop (done) -> locals.popState(...)

      when typeof f is 'function'
        switch f.length

          # Arity 0 - non async
          when 0
            r.push (done) ->

              # locals.__flowSkip = not f.bind(locals)()
              try
                result = f.bind(locals)()

                switch

                  # Boolean result means flow on/off
                  when result in [ true, false ]
                    locals.__flowSkip = not result

                  # TODO: Nested flow for array

                  # Set values, unless we're off (waiting for on flag <<true result>>)
                  when typeof result is 'object'
                    unless locals.__flowSkip
                      merge locals, result

                  else
                    throw new Error "Arity 0 flow function has to return {} or true/false."

                # setImmediate ->
                done null

              catch ex
                # setImmediate ->
                done ex

          when 1
            r.push (done) ->
              unless locals.__flowSkip
                f.bind(locals) (err, result) ->

                  # NOTE: We're merging (potentially replacing result) even
                  #       in case of errors.
                  merge locals, result
                  done err
              else
                done null

          else
            throw new Error "Wrong arity (#{f.length}) in flow for: #{f}"

  mapped = []

  map functions, mapped

  async.series mapped, (err) ->
    done.bind(locals) err, locals

module.exports = {
  flow
}

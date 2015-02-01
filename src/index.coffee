
# Merge locals (or shallow clone).
merge = (a = {}, b = {}) ->
  for own k, v of b
    a[ k ] = v
  a

# Flow.
#
# @param [Object] locals?
# @param [Array<Function>] fs
# @param [Function] done
# @return [Flow]
flow = (locals, fs, done) ->
  [ locals, fs, done ] = [ {}, locals, fs ] if typeof fs is 'function'

  # Keep track of flow state.
  skip = false

  # Index of current function to be called.
  i = 0

  # Once we reach function count we'll return.
  n = fs.length

  err = null

  # Process result.
  res = (r) ->
    switch typeof r
      when 'boolean'
        skip = not r
      when 'object'
        merge locals, r unless skip

  # Recursively call all functions and finish with final callback.
  next = ->
    if not err? and i < n
      f = fs[i++]
      switch f.length # Based on the function arity...

        # Not an async call, can be control (true/false) or vars merge (object).
        # We also ignore skip state, otherwise there would be no way of changing this state.
        when 0
          try
            res f.bind(locals)()
          catch ex
            err = ex
          next()

        # Async call.
        when 1, 2
          unless skip
            once = false
            try
              f.bind(locals) (err_, r) ->
                unless err_?
                  res r
                else
                  err = err_
                (once = true; next()) unless once
              , locals
            catch ex
              err = ex
              (once = true; next()) unless once
          else
            next()
    else

      # We're done with all calls or there was an error, return via callback.
      done.bind(locals) err, locals

  # Run.
  next null

module.exports = {
  flow
}

(function() {
  var async, flow, lshift, merge;

  async = require('async');

  lshift = require('lshift').lshift;

  merge = function(a, b) {
    var k, v;
    if (a == null) {
      a = {};
    }
    if (b == null) {
      b = {};
    }
    for (k in b) {
      v = b[k];
      if (b.hasOwnProperty(k)) {
        a[k] = v;
      }
    }
    return a;
  };

  flow = function(locals, functions, done) {
    var map, mapped, _ref;
    _ref = lshift([
      [
        locals, {
          $and: [
            'object', {
              $not: 'array'
            }
          ]
        }, {}
      ], [functions, 'array', []], [done, 'function', function() {}]
    ]), locals = _ref[0], functions = _ref[1], done = _ref[2];
    locals = merge({}, locals);
    map = function(f, r) {
      switch (false) {
        case !Array.isArray(f):
          return f.forEach(function(g) {
            return map(g, r);
          });
        case typeof f !== 'function':
          switch (f.length) {
            case 0:
              return r.push(function(done) {
                var ex, result;
                try {
                  result = f.bind(locals)();
                  switch (false) {
                    case result !== true && result !== false:
                      locals.__flowSkip = !result;
                      break;
                    case typeof result !== 'object':
                      if (!locals.__flowSkip) {
                        merge(locals, result);
                      }
                      break;
                    default:
                      throw new Error("Arity 0 flow function has to return {} or true/false.");
                  }
                  return done(null);
                } catch (_error) {
                  ex = _error;
                  return done(ex);
                }
              });
            case 1:
              return r.push(function(done) {
                if (!locals.__flowSkip) {
                  return f.bind(locals)(function(err, result) {
                    merge(locals, result);
                    return done(err);
                  });
                } else {
                  return done(null);
                }
              });
            default:
              throw new Error("Wrong arity (" + f.length + ") in flow for: " + f);
          }
      }
    };
    mapped = [];
    map(functions, mapped);
    return async.series(mapped, function(err) {
      return done.bind(locals)(err, locals);
    });
  };

  module.exports = {
    flow: flow
  };

}).call(this);

(function() {
  var async, flow, merge;

  async = require('async');

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

  flow = function(self, functions, done) {
    var map, mapped, _ref;
    if (self == null) {
      self = {};
    }
    if (Array.isArray(self)) {
      _ref = [{}, self, functions], self = _ref[0], functions = _ref[1], done = _ref[2];
    }
    self = merge({}, self);
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
                var result;
                result = f.bind(self)();
                switch (false) {
                  case result !== true && result !== false:
                    self.__flowSkip = !result;
                    break;
                  case !((typeof result === 'object') && (!Array.isArray(result))):
                    if (!self.__flowSkip) {
                      merge(self, result);
                    }
                    break;
                  default:
                    throw new Error("Arity 0 flow function has to return {} or true/false.");
                }
                return done(null);
              });
            case 1:
              return r.push(function(done) {
                if (!self.__flowSkip) {
                  return f.bind(self)(function(err, result) {
                    merge(self, result);
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
      return done.bind(self)(err, self);
    });
  };

  module.exports = {
    flow: flow
  };

}).call(this);

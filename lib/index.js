(function() {
  var flow, merge,
    __hasProp = {}.hasOwnProperty;

  merge = function(a, b) {
    var k, v;
    if (a == null) {
      a = {};
    }
    if (b == null) {
      b = {};
    }
    for (k in b) {
      if (!__hasProp.call(b, k)) continue;
      v = b[k];
      a[k] = v;
    }
    return a;
  };

  flow = function(locals, fs, done) {
    var err, i, n, next, res, skip, _ref;
    if (typeof fs === 'function') {
      _ref = [{}, locals, fs], locals = _ref[0], fs = _ref[1], done = _ref[2];
    }
    skip = false;
    i = 0;
    n = fs.length;
    err = null;
    res = function(r) {
      if (r !== null) {
        switch (typeof r) {
          case 'boolean':
            return skip = !r;
          case 'object':
            if (!skip) {
              return merge(locals, r);
            }
        }
      }
    };
    next = function() {
      var ex, f, once;
      if ((err == null) && i < n) {
        f = fs[i++];
        switch (f.length) {
          case 0:
            try {
              res(f.bind(locals)());
            } catch (_error) {
              ex = _error;
              err = ex;
            }
            return next();
          case 1:
          case 2:
            if (!skip) {
              once = false;
              try {
                return f.bind(locals)(function(err_, r) {
                  res(r);
                  err = err_;
                  if (!once) {
                    once = true;
                    return next();
                  }
                }, locals);
              } catch (_error) {
                ex = _error;
                err = ex;
                if (!once) {
                  once = true;
                  return next();
                }
              }
            } else {
              return next();
            }
        }
      } else {
        return done.bind(locals)(err, locals);
      }
    };
    return next(null);
  };

  module.exports = {
    flow: flow
  };

}).call(this);

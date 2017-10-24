var request = require('request');
var assert = require('assert');

describe('App', function() {
  it('returns status code 200', function(done) {
    request.get('localhost', function(err, res, body) {
      if (err) throw err;
      assert.equal(200, res.statusCode);
      done();
    });
  });
});

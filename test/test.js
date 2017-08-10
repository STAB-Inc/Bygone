var request = require('request');
var assert = require('assert');

describe('App', function() {
  it('returns status code 200', function(done) {
    request.get('https://stab-inc.github.io/DECO1800-Project/', function(err, res, body) {
      if (err) throw err;
      assert.equal(200, res.statusCode);
      done();
    });
  });
});

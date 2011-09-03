request = require 'request'

app = require('connect').createServer()
app.use require('../lib/assets.js')()
app.listen 3588

exports['CoffeeScript is served as JavaScript'] = (test) ->
  test.expect 3

  request 'http://localhost:3588/js/script.js', (err, res, body) ->
    test.ok !err
    test.equals res.headers['content-type'], 'application/javascript'
    expectedBody = '''
    (function() {
      console.log(\'Howdy\');
    }).call(this);\n
    '''
    test.equals body, expectedBody
    test.done()

exports['Raw JavaScript is served directly'] = (test) ->
  test.expect 3

  request 'http://localhost:3588/js/dependency.js', (err, res, body) ->
    test.ok !err
    test.equals body, '// Admit it: You need me.'
    test.equals res.headers['content-type'], 'application/javascript'
    test.done()

exports['Stylus is served as CSS'] = (test) ->
  test.expect 3

  request 'http://localhost:3588/css/style.css', (err, res, body) ->
    test.ok !err
    test.equals res.headers['content-type'], 'text/css'
    expectedBody = '''
    textarea,
    input {
      border: 1px solid #eee;
    }\n
    '''
    test.equals body, expectedBody
    test.done()

exports['Stylus imports work as expected'] = (test) ->
  test.expect 2

  request 'http://localhost:3588/css/button.css', (err, res, body) ->
    test.ok !err
    expectedBody = '''
    .button {
      -webkit-border-radius: 5px;
      -moz-border-radius: 5px;
      border-radius: 5px;
    }\n
    '''
    test.equals body, expectedBody
    test.done()

exports['nib is supported when available'] = (test) ->
  test.expect 2

  request 'http://localhost:3588/css/gradient.css', (err, res, body) ->
    test.ok !err
    expectedBody = '''
    .striped {
      background: -webkit-gradient(linear, left top, left bottom, color-stop(0, #ff0), color-stop(1, #00f));
      background: -webkit-linear-gradient(top, #ff0 0%, #00f 100%);
      background: -moz-linear-gradient(top, #ff0 0%, #00f 100%);
      background: linear-gradient(top, #ff0 0%, #00f 100%);
    }\n
    '''
    test.equals body, expectedBody
    test.done()

exports['Requests for directories are ignored'] = (test) ->
  test.expect 2

  request 'http://localhost:3588/', (err, res, body) ->
    test.ok !err
    test.equals body, 'Cannot GET /'
    test.done()

exports['Requests for nonexistent compile targets are ignored'] = (test) ->
  test.expect 2

  request 'http://localhost:3588/404.css', (err, res, body) ->
    test.ok !err
    test.equals body, 'Cannot GET /404.css'
    test.done()

exports['Requests for nonexistent raw files are ignored'] = (test) ->
  test.expect 2

  request 'http://localhost:3588/foo.bar', (err, res, body) ->
    test.ok !err
    test.equals body, 'Cannot GET /foo.bar'
    test.done()

exports['css helper function provides correct hrefs'] = (test) ->
  cssTag = "<link rel='stylesheet' href='/css/style.css'>"
  test.equals css('/css/style.css'), cssTag
  test.equals css('style.css'), cssTag
  test.equals css('style'), cssTag
  test.equals css('../style'), "<link rel='stylesheet' href='../style.css'>"
  test.done()
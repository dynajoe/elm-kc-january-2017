var Express = require('express');
var App = Express();
var Server = require('http').createServer(App);
var Path = require('path');
var Static = require('./static')

Static.initialize(App);

Server.listen(4000, function () {
   console.log('Server listening on port 4000');
});
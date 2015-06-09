// Generated by CoffeeScript 1.9.3
var Realtimer, americano, host, port, start;

americano = require('americano');

Realtimer = require('cozy-realtime-adapter');

start = function(host, port, callback) {
  return americano.start({
    name: 'Contacts',
    port: port,
    root: __dirname,
    host: host
  }, function(app, server) {
    var Contact;
    Contact = require('./server/models/contact');
    return Contact.migrateAll(function() {
      var realtime;
      realtime = Realtimer(server, ['contact.*']);
      return typeof callback === "function" ? callback(null, app, server) : void 0;
    });
  });
};

if (!module.parent) {
  host = process.env.HOST || '127.0.0.1';
  port = process.env.PORT || 9114;
  start(host, port, function(err) {
    if (err) {
      console.log("Initialization failed, not starting");
      console.log(err.stack);
      return process.exit(1);
    }
  });
} else {
  module.exports = start;
}

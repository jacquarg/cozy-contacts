// Generated by CoffeeScript 1.8.0
var Contact, async;

Contact = require('../models/contact');

async = require('async');

module.exports = function(next) {
  return Contact.rawRequest('all', function(err, contacts) {
    if (err) {
      return next(err);
    }
    return async.forEachSeries(contacts, function(contact, cb) {
      var data, dp, _i, _len, _ref;
      contact = contact.value;
      if (contact.fn || contact.n) {
        return cb(null);
      }
      console.log("patch1 on contact", contact.id);
      data = {};
      data.fn = contact.name;
      data.note = contact.notes + "\n";
      if (contact.datapoints) {
        _ref = contact.datapoints;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dp = _ref[_i];
          data.note += dp.name + " " + dp.type + " " + dp.value + "\n";
        }
      }
      return Contact.create(data, function(err) {
        if (err) {
          console.log(err.stack);
          return cb(err);
        }
        return Contact.find(contact._id, function(err, contact) {
          if (err) {
            console.log(err.stack);
            return cb(err);
          }
          return contact.destroy(cb);
        });
      });
    }, next);
  });
};

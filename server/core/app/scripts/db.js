var mongoose = require('mongoose');
var Q = require('q');

var DB = function (config) {
	this.config = config;
	this.createPromise();
	this.setupMongo();
};

var p = DB.prototype = {};

p.createPromise = function () {
	this._deferred = Q.defer();
	this.promise = this._deferred.promise;
};

p.setupMongo = function () {
	mongoose.connect(this.config.uri, this.config.opts);

	mongoose.connection
		.on('open', function() {
			this._deferred.resolve();	
		}.bind(this))
		.on('error', function() {
			this._deferred.reject();
		}.bind(this));
};

DB.Mongodb = function (config) {
	return new DB(config);
}

module.exports = DB;


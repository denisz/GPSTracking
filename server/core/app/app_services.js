var Q 			= require('q');
var Broker 		= require('gt-broker');
var DB 			= require('gt-db');
var Cache 		= require('gt-cache');
var brokers 	= require('../services');

var broker 		= Broker.RabbitMQ({
	url 		: 'amqp://guest:guest@localhost:5672', 
	heartbeat 	: 10
});

var db 	=  DB.Mongodb({
	uri 	: 'mongodb://tracking:tracking@localhost:27017/tracking',
	opts 	: {
		mongos: true
	}
});

var cache = Cache.createClient();
var start = function () {
	broker 	.use('account', 	brokers.Account);
	broker 	.use('event',   	brokers.Event);
	broker 	.use('comment', 	brokers.Comment);
	broker 	.use('auth', 		brokers.Auth);
	broker  .use('checkin', 	brokers.Checkin);
	broker  .use('answer',  	brokers.Answer);
	broker  .use('favorite',  	brokers.Favorite);
	broker  .use('angry',  		brokers.Angry);
	broker  .use('attachment',  brokers.Attachment);
};

Q.allSettled([broker.promise, db.promise, cache.promise])
	.then(function (results) {
		var tryStart = true;

		results.forEach(function (result, index) {
			if (result.state !== "fulfilled") {
				console.log("Error reason ", result.reason);
				console.log("Error service index ", index);
				tryStart = false;
			}
		});

		if (tryStart == true) {
			start();
		}
	})
	.fail(function(e) {
		console.log("Error connection to db or rabbitmq || redis", e);
	});

module.exports = function (app) {
	app.set('cache', cache);
	app.set('db', db);
	broker.set('app', app);
};
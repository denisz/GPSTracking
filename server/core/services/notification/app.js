var _ = require('underscore');
var express 	= require('express');
var Broker 		= require('gt-broker');
var ctrl 		= require('./scripts/controller');
var DB 			= require('gt-db');
var morgan 		= require('morgan');
var expressWs   = require('express-ws')(express());
var Driver 		= require('gt-driver');
var session 	= require('gt-session');

var app 		= expressWs.app;

var driver 		= Driver.RabbitMQ({
	url 		: 'amqp://guest:guest@localhost:5672', 
	heartbeat 	: 10
});

var broker 		= Broker.RabbitMQ({
	url 		: "amqp://guest:guest@localhost:5672", 
	heartbeat 	: 10
});

app.use(session());

broker.promise
	.then(function(){
		broker 	.use('notify',  ctrl);
		app		.use('/notify', ctrl);		
	})
	.fail(function(){
		console.log("Error connection to rabbitmq");
	});

app.ws('/notify', function(ws, res, next) {
	ctrl.handle(ws.upgradeReq, ws, next);	
});

app.set('ws', 		expressWs.getWss('/notify'));
app.set('driver', 	driver);
broker.set('app', 	app);

app.use(morgan('combined'));

app.listen(process.env.PORT, function () {
	console.log("Server started on port " + process.env.PORT);
});
var Express 	= require('express');
var Broker 		= require('gt-broker');
var ctrl 		= require('./scripts/controller');
var DB 			= require('gt-db');
var morgan 		= require('morgan');

var app 		= Express();
var broker 		= Broker.RabbitMQ({
	url 		: "amqp://guest:guest@localhost:5672", 
	heartbeat 	: 10
});


var db 	=  DB.Mongodb({
	uri 	: 'mongodb://tracking:tracking@localhost:27017/tracking',
	opts 	: {
		mongos: true
	}
});

db.promise.then(function(){
	broker 	.use('attachment', ctrl);
	app		.use('/attachment', ctrl);
});

broker.set('app', app);
app.set('db', db);
app.use(morgan('combined'));

app.listen(process.env.PORT, function () {
	console.log("Server started on port " + process.env.PORT);
});
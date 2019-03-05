var Express 	= require('express');
var Broker 		= require('gt-broker');
var ctrl 		= require('./scripts/controller');
var morgan 		= require('morgan');

var app 		= Express();
var broker 		= Broker.RabbitMQ({
	url 		: "amqp://guest:guest@localhost:5672", 
	heartbeat 	: 10
});

broker 	.use('checkin', ctrl);
app		.use('/checkin', ctrl);

broker.set('app', app);
app.use(morgan('combined'));

app.listen(process.env.PORT, function () {
	console.log("Server started on port " + process.env.PORT);
});
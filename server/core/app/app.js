var express 			= require('express');
var bodyParser 			= require('body-parser');
var multer 				= require('multer'); 
var configure 			= require('./configure');
var useragent 			= require('express-useragent');
var morgan 				= require('morgan');
var ctrls 				= require('./controllers'); 
var expressValidator 	= require('express-validator');
var errFormatter  		= require('./scripts/errorFormatter');
var Driver 				= require('gt-driver');
var session 			= require('gt-session');

var app 		= express();
var driver 		= Driver.RabbitMQ({
	url 		: 'amqp://guest:guest@localhost:5672', 
	heartbeat 	: 10
});
var services 	= require('./app_services')(app);

app.set('driver', driver);
app.use('/static/uploads', express.static('uploads'));
app.use(session());
app.use(useragent.express());
app.use(bodyParser.json()); 								// for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); 		// for parsing application/x-www-form-urlencoded
app.use(expressValidator({errorFormatter : errFormatter}));	// validator


//controllers
app.use('/account', 	ctrls.Account);
app.use('/auth', 		ctrls.Auth);
app.use('/session', 	ctrls.Session);
app.use('/event', 		ctrls.Event);
app.use('/comment', 	ctrls.Comment);
app.use('/user', 		ctrls.User);
app.use('/answer',  	ctrls.Answer);
app.use('/group',   	ctrls.Group);
app.use('/follower',   	ctrls.Follower);
app.use('/checkin',   	ctrls.Checkin);
app.use('/upload', 		ctrls.Upload);
app.use('/favorite', 	ctrls.Favorite);
app.use('/attachment', 	ctrls.Attachment);

app.use(morgan('combined'));

app.listen(process.env.PORT || 3000, function () {
	console.log('Server started on port ' + process.env.PORT);
});
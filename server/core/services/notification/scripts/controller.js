var Router 					= require('./router');
var serialize 				= require('gt-serialize');
var Error 					= require('gt-error');
var Errors 					= require('gt-errors');
var transport 				= require('./transports');
var helper 					= require('./helper');
var errorHandler 			= require('gt-error-handling');

var requireAuthentication 	= require('./requireAuthentication');
var router 					= new Router();

router.all('/notify', requireAuthentication, function(req, res, next){
	var session = req.session;
	transport.socket.subscribe(session, res);
	
	res.on('message', function(msg) {
		res.send("ok");
	});

	res.on('close', function(code, reason) {
		transport.socket.unsubscribe(session);
	});

	res.send("hello");
});

router.subscribe('/email', function(req, res, next){
});

router.subscribe('/instance/user', function(req, res, next) {
	var driver  	= req.app.get('driver');
	var user_id 	= req.body.user;
	var data 		= req.body.data;
	var command 	= req.body.command;
	var tmpl    	= helper.parseTmplFromCommand(command);

	var alert = helper.render(tmpl, "ru", data);
	var message 	= {
		command  : command,
		data  	 : data
	};

	driver.command("auth/device", {user_id: user_id}).then(function(data) {
		var items = data.items;

		for (var i = 0,l = items.length; i < l; i++) {
			if (items[i].apn_token) {
				transport.apn.send(items[i].apn_token, alert, message);
			}
		}
	});

	res.send(serialize.ok());
});

//@params - users массив ids
router.subscribe('/instance/devices', function(req, res, next) {
	var driver  	= req.app.get('driver');
	var devices 	= req.body.devices;
	var data 		= req.body.data;
	var command 	= req.body.command;
	var tmpl    	= helper.parseTmplFromCommand(command);

	var alert = helper.render(tmpl, "ru", data);
	var message 	= {
		command  : command,
		data  	 : data
	};

	console.log(devices, alert);

	for (var i = 0, l = devices.length; i < l; i++) {
		transport.apn.send(devices[i], alert, message);
	}

	res.send(serialize.ok());
});

router.use(errorHandler);

module.exports = router;
var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');
var Errors 					= require('gt-errors');

var router = new Router();

router.all('/apn', validator('session/apn'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'device_token');

	params.user_id = req.session.user_id;
	params.session_id = req.session.session_id;

	console.log(params);

	driver.command('auth/updateapn', params)
		.then(function(data){
			return serialize.ok();
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();
		})
});

router.all('/gcm', validator('session/gcm'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'device_token');

	params.user_id = req.session.user_id;
	params.session_id = req.session.session_id;

	driver.command('auth/updategcm', params)
		.then(function(data){
			return serialize.ok();
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();
		})
});

router.use(errorHandling);

module.exports = router;
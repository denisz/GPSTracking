var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var loadUser 				= require('../scripts/loadUser');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');
var Errors 					= require('gt-errors');

var router = new Router();

router.all('/whoisiam', requireAuthentication, loadUser, function (req, res, next) {
	var result = "";

	if (req.user) {
		result = serialize.success({
			user 	: req.user,
			session : req.session
		})
	}  else {
		result = serialize.error(new Error(Errors.UserAuthorizationFailed));
	}

	res.json(result);
});

router.all('/ping', function(req, res, next){
	var driver = req.app.get('driver');

	driver.message('auth/ping/test', { ok: true})
		.then(function(){
			return serialize.ok();
		})
		.fail(function(){
			return serialize.error(new Error(Errors.InvalidRequest))
		})
		.done(function(result){
			res.json(result);
			next();
		})
});

router.all('/logout', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = {
		user_id: req.session.user_id
	};
	
	driver.command('auth/remove', params)
		.then(function(dataAuth) {
			return serialize.ok();		
		})
		.fail(function(data) {
			return serialize.error(data);
		})
		.done(function (result) {
			res.json(result);
			next();
		})
});

router.use(errorHandling);

module.exports = router;
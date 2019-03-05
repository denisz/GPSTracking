var _ = require('underscore');
var Router 					= require('../scripts/router');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var rules 					= require('../scripts/validator');
var validator  			 	= require('gt-validator');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var requireAccess 			= require('../scripts/requireAccess');
var helperList 				= require('../helper/list');


var router = new Router();

router.all('/login', validator(rules, '/account/login'), function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'email', 'password');

	driver.command('account/login', params)
		.then(function(dataLogin) {
			var user = dataLogin.user;

			driver.command('auth/create', { email: user.email, user_id : user._id, useragent : req.useragent.source, ip : req.ip })
				.then(function(dataAuth) {
					_.extend(dataLogin, dataAuth); 
					return serialize.success(dataLogin);
				})
				.fail(function(data){
					return serialize.error(data);
				})
				.done(function(result){
					res.json(result);
					next();
				})				
		})
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		})
});


router.all('/login/social/fb', validator(rules, '/account/social/fb'), function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'access_token');
	
	driver.command('account/social/fb', params)
		.then(function(dataLogin) {
			var user = dataLogin.user;

			driver.command('auth/create', { email: user.email, user_id : user._id, useragent : req.useragent.source, ip : req.ip })
				.then(function(dataAuth) {
					_.extend(dataLogin, dataAuth); 
					return serialize.success(dataLogin);
				})
				.fail(function(data){
					return serialize.error(data);
				})
				.done(function(result){
					res.json(result);
					next();
				})				
		})
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		})
});

router.all('/link/social/fb', validator(rules, '/account/social/fb'), requireAuthentication, function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'access_token');

	driver.command('account/link/fb', params)
		.then(function(dataLogin) {
			return serialize.success(dataLogin);
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();	
		})
});

router.all('/banned', requireAuthentication, requireAccess(['admin', 'superuser']), function(req, res, next) {

});

router.all('/changepwd', validator('account/changepwd'), function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'email', 'newpassword', 'hash');

	driver.command('account/changepwd', params)
		.then(function(data){
			//driver.message('notify/email/resetpwd', data);//пользователь
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

router.all('/resetpswd', validator(rules, 'account/resetpswd'), function (req, res, next) {
	var params = _.pick(req.body, 'email');

	driver.command('account/resetpswd', params)
		.then(function(data){
			//driver.message('notify/email/resetpwd', data);//пользователь
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

router.all('/register', validator(rules, 'account/register'), function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'email', 'password', 'fullname');
	
	driver.command('account/register', params)
		.then(function(dataRegister) {
			var user = dataRegister.user;

			driver.command('auth/create', { email: user.email, user_id : user._id, useragent : req.useragent.source, ip : req.ip })
				.then(function(dataAuth) {
					_.extend(dataRegister, dataAuth);
					return serialize.success(dataRegister);
				})
				.fail(function(data){
					return serialize.error(data);
				})
				.done(function(result){
					res.json(result);
					next();
				})	
		})
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		});
});

router.all('/push', requireAuthentication, function(req, res, next){
	var driver = req.app.get('driver');
	var data = [req.session.session_id];

	driver.message('notify/instance', {
		data 		: {
			id : 1
		},
		sessions 	: data,
		command 	: 'near_request_instance'
	});

	res.json(serialize.ok());
});


router.use(errorHandling);

module.exports = router;
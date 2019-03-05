var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');


var router = new Router();

router.all('/get', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;

	driver.command('attachment/get', params)
		.then(function(data) {
			return serialize.success(data);	
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function (result) {
			res.json(result);
			next();
		})
});

router.all('/delete', requireAuthentication, function(req, res, next) {

	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;

	driver.command('attachment/delete', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function (result) {
			res.json(result);
			next();
		})

});

//список ответов события
router.all('/list/scope', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'ids', 'target_id');
	
	params.owner_id = req.session.user_id;
	
	driver.command('attachment/list/scope', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data) {
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();	
		})
});

//список ответов события
router.all('/list/user', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');
	
	params.owner_id = req.session.user_id;

	driver.command('attachment/list/user', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data) {
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();	
		})
});

router.get('/target', requireAuthentication, function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id', 'target_id');

	params.owner_id = req.session.user_id;

	driver.command('attachment/target', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data) {
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();
		})
});

router.all('/list/target', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id', 'target_id');
	
	params.owner_id = req.session.user_id;
	
	driver.command('attachment/list/target', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data) {
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();	
		})
});

router.use(errorHandling);

module.exports = router;
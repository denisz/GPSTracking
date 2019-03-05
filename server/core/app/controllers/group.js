var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var loadUser 				= require('../scripts/loadUser');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');

var helperList 				= require('../helper/list');
var faker 					= require('faker');

var router = new Router();

router.all('/create', validator('group/create'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'description', 'mark', 'title');

	params.owner_id = req.session.user_id;	

	driver.command('group/create', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();
		})
});

router.all('/get', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	driver.command('group/get', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(serialize.error(data));
			next();
		})		
});

router.all('/update', requireAuthentication, function (req, res, next) {});

router.all('/delete', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	driver.command('group/delete', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(serialize.error(data));
			next();
		})		
});

router.use(errorHandling);

module.exports = router;
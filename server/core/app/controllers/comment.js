var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');
var helperList 				= require('../helper/list');

var router 	= new Router();

router.all('/create', validator('comment/create'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'body', 'target_id');

	params.owner_id  = req.session.user_id;
	
	driver.command('comment/create', params)
		.then(function(data) {
			//
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

router.all('/delete', requireAuthentication, function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;

	driver.command('comment/delete', params)
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

//список комментариев ответа
router.all('/list/answer', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id', 'target_id');

	params.owner_id  = req.session.user_id;

	driver.command('comment/list/answer', params)
		.then(function(list) {
			driver.command('account/ids', {ids: helperList.pluck(list, 'owner_id')})
				.then(function(extra) {
					return serialize.listWithExtra(list, extra, 'user');
				})
				.fail(function(data) {
					return serialize.error(data)
				})
				.done(function(result) {
					res.json(result);
					next();
				})			
		})
		.fail(function(data) {
			res.json(serialize.error(data));
			next();
		})
});

//список комментариев пользователя
router.all('/list/user', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');

	params.owner_id  = req.session.user_id;

	driver.command('comment/list/user', params)
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
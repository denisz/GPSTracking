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
	var params = _.pick(req.body, 'target_id');

	params.user_id = req.session.user_id;	

	driver.command('follower/create', params)
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

//список групп пользователя
//добавить нормальную валидацию для списков
router.all('/list/user', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id', 'owner_id');

	driver.command('follower/list/user', params)
		.then(function(list) {
			driver.command('group/ids', {ids: helperList.pluck(list, 'target_id')})
				.then(function(extra) {
					return serialize.listWithExtra(list, extra, 'group');
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

router.all('/delete', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	driver.command('follower/delete', params)
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
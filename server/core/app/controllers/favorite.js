var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');

var helperList 		= require('../helper/list');
var router 			= new Router();

router.all('/create', requireAuthentication, validator('favorite/create'), function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'event_id');

	params.owner_id = req.session.user_id;

	driver.command('favorite/create', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data){
			return serialize.error(data);
		})
		.done(function(result){
			res.json(result);
			next();
		});
});

router.all('/delete', requireAuthentication, function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;

	driver.command('favorite/delete', params)
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

//список избранных событий
router.all('/list/user', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');

	params.owner_id = req.session.user_id;

	driver.command('favorite/list/user', params)
		.then(function(favorites) {

			driver.command('event/ids', {ids: helperList.pluck(favorites, 'event_id')})
				.then(function(events) {

					driver.command('account/ids', {ids: helperList.pluck(events, 'owner_id')})
						.then(function(users) {
							//serialize.listWithExtra(events, favorites, 'favorite');
							return serialize.listWithExtra(events, users, 'user')
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
					return res.json(serialize.error(data));
				});
		})
		.fail(function(data) {
			serialize.error(data);
			next()
		})
});

router.use(errorHandling);

module.exports = router;
var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');
var helperList 				= require('../helper/list');
var helperEvent 			= require('../helper/event');

var router = new Router();

router.all('/create', validator('event/create'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'description', 'criteria', 'loc', 'allow_phone', 'allow_email', 'localized_loc');

    //если пропажа исправить на полигон (окружность с центром в городе и нужного радиуса зависящего от площади)
    //ввести понятия оповещений
	params.owner_id = req.session.user_id;	

	driver.command('event/create', params)
		.then(function(data) {
			var event = data.event;
			try{
				helperEvent.notify(req, event);
			} catch(e) {
				console.log(e);
			}

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

router.all('/broadcast', requireAuthentication, function(req, res, next) {
	// var driver = req.app.get('driver');
	
	// driver.command('account/list/all', {})
	// 	.then(function(list) {
	// 		var ids = helperList.pluck(list, '_id');

	// 		driver.message('notify/instance', {
	// 			tmpl : 'near_request', 
	// 			event: {},
	// 			users: ids
	// 		});					
	// 	})
	// 	.fail(function(data){
	// 		console.log("[checkin/near]", data);
	// 	});

	res.json(serialize.ok());
});

router.all('/get', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	driver.command('event/get', params)
		.then(function(data) {
			var owner_id = data.event.owner_id;

			var after = _.after(3, function(result) {
				res.json(result);
				next();
			});

			driver.command('answer/is', { owner_id: req.session.user_id, event_id: data.event._id})
				.then(function(answer){
					_.extend(data, answer)
					return serialize.success(data);
				})				
				.fail(function(){
					return serialize.success(data);						
				})
				.done(function(result){
					after(result);
				});

			driver.command('favorite/is', { owner_id: req.session.user_id, event_id: data.event._id})
				.then(function(favorite){
					_.extend(data, favorite)
					return serialize.success(data);
				})
				.fail(function(){
					return serialize.success(data);
				})
				.done(function(result){
					after(result);
				});

			driver.command('account/get', {id: owner_id})
				.then(function(user){
					_.extend(data, user)
					return serialize.success(data);
				})
				.fail(function(data){
					return serialize.error(data);
				})
				.done(function(result){
					after(result);
				})
		})
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		})		
});

router.all('/delete', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;	

	driver.command('event/delete', params)
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

router.all('/angry', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'target_id', 'reason');

	params.owner_id = req.session.user_id;

	driver.command('angry/create', params)
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

router.all('/count/angry', requireAuthentication, function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'target_id');

	params.owner_id = req.session.user_id;

	driver.command('angry/count/target', params)
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

router.all('/update', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;	

	driver.command('event/update', params)
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

//список событий пользователя
//добавить нормальную валидацию для списков
router.all('/list/user', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id', 'owner_id');

	driver.command('event/list/user', params)
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

//активные запросы пользователя
router.all('/list/active', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');

	params.owner_id = req.session.user_id;

	driver.command('event/list/active', params)
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

//отмененные запросы пользователя
router.all('/list/canceled', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');

	params.owner_id = req.session.user_id;

	driver.command('event/list/canceled', params)
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

//избранные запросы пользователя
router.all('/list/favorites', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');

	params.owner_id = req.session.user_id;

	driver.command('event/list/favorites', params)
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

//события рядом
router.all('/list/near', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'loc');
	var owner_id = req.session.user_id;
	params.owner_id = owner_id;

	driver.command('event/list/near', params)
		.then(function(list) {

			console.log(helperList.count(list));

			var ids = helperList.pluck(list, '_id');

			if (ids.length == 0) {
				var result = serialize.list(list);
				res.json(result);
				next();
			}  else {
				console.log(ids);
				driver.command('answer/is/ids', {ids: ids, owner_id: owner_id})
					.then(function(extra) {
						var idsEventWithAnswer = helperList.pluck(extra, 'event_id');
						helperList.exclude(list, "_id", idsEventWithAnswer);
						console.log(idsEventWithAnswer)
						console.log(helperList.count(list));
						return serialize.success(list);
					})
					.fail(function(data) {
						return serialize.error(data)
					})
					.done(function(result) {
						res.json(result);
						next();
					});
			}

		})
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		})
});

//пропущенные
router.all('/list/missed', requireAuthentication, function (req, res, next) {
	res.json(serialize.error(new Error(Errors.InvalidRequest)));	
});

//архив
router.all('/list/filter', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'loc', 'from', 'to', 'context', 'last_id', 'subtype');

	params.owner_id = req.session.user_id;

	driver.command('event/list/filter', params)
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
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		})
});

//очевидцы заропса
router.all('/list/spectator', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;

	driver.command('event/list/spectator', params)
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
		.fail(function(data){
			res.json(serialize.error(data));
			next();
		})
});

router.all('/cancel', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	params.owner_id = req.session.user_id;

	driver.command('event/cancel', params) 
		.then(function(data) {
			driver.command('answer/scope/cancel', { target_id: params.id});
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

router.all('/angry', requireAuthentication, function (req, res, next) {
	
});

router.use(errorHandling);

module.exports = router;
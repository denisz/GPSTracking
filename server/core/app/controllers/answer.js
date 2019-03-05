var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');

var helperList 		= require('../helper/list');
var helperEvent 	= require('../helper/event');
var router 			= new Router();


router.all('/create', requireAuthentication, validator('answer/create'), function (req, res, next) {
	var driver			= req.app.get('driver');
	var params 			= _.pick(req.body, 'loc', 'localized_loc', 'event_id', 'description', 'status');

	params.owner_id = req.session.user_id;

	driver.command('answer/is', params)
		.then(function(answer){
			var comment = {};
			comment.owner_id 	= req.session.user_id;
			comment.target_id 	= data.answer._id;
			comment.body 		= params.description;

			driver.command('comment/create', comment)
				.then(function(data) {
					return serialize.success(answer);
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
			driver.command('answer/create', params)
				.then(function(data) {
					//создаем ответ и оповещаем автора запроса о новом ответе
					helperEvent.notifyAuthorRequestById(req, params.event_id, "new_answer");
					return 	serialize.success(data);
				})
				.fail(function(data) {
					return serialize.error(data);
				})
				.done(function (result) {
					res.json(result);
					next();
				})
		})

	
});

router.all('/update', requireAuthentication, validator('answer/update'), function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'loc', 'id', 'localized_loc', 'event_id', 'description', 'status');

	params.owner_id = req.session.user_id;
	//отправить сообщение владельцу события
	
	driver.command('answer/update', params)
		.then(function(data) {
			return 	serialize.success(data);		
		})
		.fail(function(data) {
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

	driver.command('answer/delete', params)
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


router.all('/get', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	driver.command('answer/get', params)
		.then(function(data) {
			var owner_id = data.event.owner_id;
			
			driver.command('account/get', {id: owner_id})
				.then(function(user){
					_.extend(data, user);
					return serialize.success(data);
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


//список ответов события
router.all('/list/event', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id', 'event_id');

//добавить проверку что запрос пользователя иначе любой сможет смотреть ответы, что очень плохо
	driver.command('answer/list/event', params)
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

//список ответов события
router.all('/list/user', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');
	
	params.owner_id = req.session.user_id;

	driver.command('answer/list/user', params)
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

//список ответов на которые ответил пользователь
//лента
router.all('/list/perform', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'last_id');
	
	params.owner_id = req.session.user_id;

	driver.command('answer/list/perform', params)
		.then(function(answers) {

			console.log(answers);
			driver.command('event/ids', {ids: helperList.pluck(answers, 'event_id')})
				.then(function(events) {

					driver.command('account/ids', {ids: helperList.pluck(events, 'owner_id')})
						.then(function(users) {
							serialize.listWithExtra(answers, events, 'event');
							return serialize.listWithExtra(answers, users, 'user');
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
				})
		})
		.fail(function(data) {
			return res.json(serialize.error(data));
		})
});

router.use(errorHandling);

module.exports = router;
var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');
var helperEvent 			= require('../helper/event');

var router = new Router();

router.all('/get', requireAuthentication, function(req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'id');

	driver.command('account/get', params)
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

//изменение email вынести отдельно
router.all('/update', validator('user/update'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'email', 'fullname', 'password', 'phone', 'avatar', 'cover', 'settings');

	params.user_id = req.session.user_id;
	params.phone = helperEvent.normalizePhone(params.phone);

	driver.command('account/update', params)
		.then(function(data) {
			//оповещеаем что были изменены настройки
			driver.command('notify/email', {
				users 	: [req.session.user_id],
				command : "change_settings"
			});
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

router.use(errorHandling);

module.exports = router;
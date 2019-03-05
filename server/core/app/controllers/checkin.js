var _ = require('underscore');
var Router 					= require('../scripts/router');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var loadUser 				= require('../scripts/loadUser');
var serialize 				= require('gt-serialize');
var Errors 					= require('gt-errors');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');

var router = new Router();

router.all('/create', validator('checkin/create'), requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = _.pick(req.body, 'latitude', 'longitude');

	params.id 			= req.session.apn_token;//req.session.apn_token//устройство
	params.owner_id 	= req.session.user_id;

	if (!params.id) {
		return serialize.error(Errors.InvalidParameters);
	}

	driver.command('checkin/create', params)
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

router.all('/get', requireAuthentication, function(req, res, next){
	var driver = req.app.get('driver');
	var params = {};

	params.session_id 	= req.session.session_id;
	params.owner_id 	= req.session.user_id;

	driver.command('checkin/get', params)
		.then(function(data) {
			return serialize.success(data);		
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
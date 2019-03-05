var _ = require('underscore');
var Router 					= require('../scripts/router');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var validator  			 	= require('gt-validator');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var requireAccess 			= require('../scripts/requireAccess');

var router = new Router();

router.all('/register', requireAuthentication, function (req, res, next) {
	var driver = req.app.get('driver');
	var params = {};

	driver.command('notify/register', params)
		.then(function(data) {
			return serialize.success(data);
		})
		.fail(function(data){
			return serialize.error(data);		
		})
		.done(function(result) {
			res.json();
			next();
		})
});

router.use(errorHandling);

module.exports = router;
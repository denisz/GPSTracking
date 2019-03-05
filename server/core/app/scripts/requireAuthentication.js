var serialize 	= require('gt-serialize');
var errors 		= require('gt-errors');
var Error 		= require('gt-error');
var debug 		= require('debug')('auth');
 
var RequireAuthentication = function (req, res, next) {
	var driver = req.app.get('driver');
	var params = {
		session_id : req.sessionID
	};

	if (!params.session_id) {
		throw new Error(errors.AccessDenied);
	}

	//сессию мы уже  загрузили
	if (req.session) {
		next();
	} else {
		driver.command('auth/get', params)
			.then(function(dataAuth) {
				req.session = dataAuth.session;
				next();			
				return dataAuth;
			})
			.fail(function(data){
				res.json(serialize.error(data));			
				return data;
			})	
			.done(function(result){
				debug(result);
			})	
	}
	
};

module.exports = RequireAuthentication;
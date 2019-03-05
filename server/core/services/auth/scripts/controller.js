var Router 				= require('./router');
var Errors 				= require('gt-errors');
var response 			= require('gt-response');
var mongoose 			= require('mongoose');
var Schema  			= require('./schemas/session');
var errorHandler 		= require('gt-error-handling');
var uuid 				= require('uuid');

var Model  		= mongoose.model('Session', Schema);
var router 		= new Router();
var formName 	= "session";

router.get('/get', function (req, res, next) {
	var session_id = req.body.session_id;
	Model.findOne({ session_id: session_id }, null, {sort: {created_at: -1 }}, response.form(res, formName, Errors.UserAuthorizationFailed, Errors.UserAuthorizationFailed));
});

router.get('/user', function (req, res, next) {
	var user_id = req.body.user_id;
	Model.findOne({ user_id: user_id }, null, {sort: {created_at: -1 }}, response.form(res, formName, Errors.UserAuthorizationFailed, Errors.UserAuthorizationFailed));
});

router.get('/remove', function (req, res, next) {
	var params 	= req.body;
	var user_id = mongoose.Types.ObjectId(params.user_id);

	Model.remove({user_id: user_id }, response.ok(res));
});

router.get('/create', function(req, res, next) {
	var params 	= req.body;
	
	Model.create({ 
		session_id 	: uuid(),
		user_id 	: mongoose.Types.ObjectId(params.user_id), 
		ua 			: params.useragent
	}, response.form(res, formName));
});

//get sessions list by ids users
router.get('/ids', function (req, res, next) {
	var params 	= req.body;
	var ids 	= params.ids;

	if (!Array.isArray(ids)) {
		response.error(res, Errors.InternalServiceError);
	} else {
		Model.find({ session_id : {$in : ids}}, response.list(res, req))
	}
});

router.get('/device', function(req, res, next) {
	var params 	= req.body;

	var conditions	= {
		user_id : mongoose.Types.ObjectId(params.user_id),
		apn_token: {
			$exists: true
		}
	};

	Model.find(conditions, response.list(res, req))
});

//update apn token for ios device
router.get('/updateapn', function(req, res, next) {
	var params 	= req.body;

	var options 	= { 'new': true };
	var conditions	= {
		user_id 		: params.user_id,
		session_id 		: params.session_id
	};
	var update  = {
		apn_token : params.device_token
	};

	Model.findOneAndUpdate(conditions, update, options, response.ok(res))
});

//update apn token for android device
router.get('/updategcm', function(req, res, next) {
	var params 	= req.body;

	var options 	= { 'new': true };
	var conditions	= {
		user_id 		: params.user_id,
		session_id 		: params.session_id
	};
	var update  = {
		gcm_token : params.device_token
	};

	Model.findOneAndUpdate(conditions, update, options, response.ok(res))
});

router.use(errorHandler);

module.exports = router;
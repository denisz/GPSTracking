var _ = require('underscore');
var Router 				= require('./router');
var response 			= require('gt-response');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/angry');
var errorHandler 		= require('gt-error-handling');
var listTransform 		= require('gt-list');

var Model 	= mongoose.model('Angry', schema);
var router 	= new Router();
var formName = "angry";
var limit = 6;

//insert
router.get('/create', function (req, res, next) {
	var params = req.body;
	var favorite = _.pick(params, 'owner_id', 'reason', 'target_id');

	favorite.reason = parseInt(favorite.reason, 10);
	favorite.target_id = mongoose.Types.ObjectId(favorite.target_id);
	favorite.owner_id  = mongoose.Types.ObjectId(favorite.owner_id);

	Model.create(favorite, response.form(res, formName))
});

//вернуть список жалоб пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function (req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id : mongoose.Types.ObjectId(params.owner_id)
		}
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//вернуть количество жалоб
router.get('/count/target', function (req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			target_id 	 : mongoose.Types.ObjectId(params.target_id)
		}
	};

	Model.aggregate(conditions).count(function(err, count) {
		if (err) {
			response.error(res, new Error(Errors.InternalServiceError, err.errmsg));
		} else {
			response.form(res, formName)(err, {count : count});
		}
	});
});

router.use(errorHandler);

module.exports = router;
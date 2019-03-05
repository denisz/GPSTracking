var _ = require('underscore');
var Router 				= require('./router');
var response 			= require('gt-response');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/favorite');
var errorHandler 		= require('gt-error-handling');
var listTransform 		= require('gt-list');

var Model 	= mongoose.model('Favorite', schema);
var router 	= new Router();
var formName = "favorite";
var limit = 6;

//insert
router.get('/create', function (req, res, next) {
	var params = req.body;
	var favorite = _.pick(params, 'owner_id', 'event_id');

	favorite.event_id  = mongoose.Types.ObjectId(favorite.event_id);
	favorite.owner_id  = mongoose.Types.ObjectId(favorite.owner_id);
	favorite.mark_deleted = false;

	Model.findOneAndUpdate({
		event_id : favorite.event_id,
		owner_id : favorite.owner_id
	}, favorite, {
		'new' 	: true,
		upsert  : true
	}).exec(response.form(res, formName));

//	Model.findOneAndUpdate({
//		event_id : favorite.event_id,
//		owner_id : favorite.owner_id
//	}, favorite, {upsert: true}, response.form(res, formName));
});

//вернуть список избраннных пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function (req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
			mark_deleted : false
		}
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

router.get('/is', function(req, res, next) {
	var conditions = {
		owner_id 		: mongoose.Types.ObjectId(req.body.owner_id),
		event_id 		: mongoose.Types.ObjectId(req.body.event_id),
		mark_deleted 	: false
	};

	Model.findOne(conditions, response.form(res, formName))
});

//удалить избранное
router.get('/delete', function (req, res, next) {
	var conditions = {
		_id 	: mongoose.Types.ObjectId(req.body.id),
		owner_id: mongoose.Types.ObjectId(req.body.owner_id)
	};

	var update = {
		mark_deleted : true
	};

	var options = { 'new' : true };
	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName));
});

router.use(errorHandler);

module.exports = router;
var _ = require('underscore');
var Router 				= require('./router');
var response 			= require('gt-response');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/comment');
var errorHandler 		= require('gt-error-handling');
var listTransform 		= require('gt-list');

var Model 	= mongoose.model('Comment', schema);
var router 	= new Router();
var formName = "comment";
var limit = 6;

//insert
router.get('/create', function (req, res, next) {
	var params = req.body;
	var comment = _.pick(params, 'owner_id', 'body', 'target_id');

	comment.target_id = mongoose.Types.ObjectId(comment.target_id);
	comment.owner_id  = mongoose.Types.ObjectId(comment.owner_id);

	Model.create(comment, response.form(res, formName))
});

//список комментариев ответа
router.get('/list/answer', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			//owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
			target_id 	 : mongoose.Types.ObjectId(params.target_id),
			status 		 : 'active',
			mark_deleted : false
		}		
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//вернуть список комментариев пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function (req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
			status 		 : 'active',
			mark_deleted : false
		}		
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//удалить комментарий
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
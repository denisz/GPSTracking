var _ = require('underscore');
var Router 				= require('./router');
var serialize 			= require('gt-serialize');
var Error 				= require('gt-error');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/attachment');
var errorHandler 		= require('gt-error-handling');
var response 			= require('gt-response');
var listTransform 		= require('gt-list');

var Model 	= mongoose.model('Attachment', schema);
var router 	= new Router();

var formName = "attachment";

//insert
router.get('/create', function (req, res, next) {
	var params 		= req.body;
	var attachment 	= _.pick(params, 'owner_id', 'size', 'thumb_s', 'thumb_b', 'ext', 'path', 'type', 'name', 'target_id');
	
	attachment.target_id = mongoose.Types.ObjectId(attachment.target_id);
	attachment.owner_id  = mongoose.Types.ObjectId(attachment.owner_id);

	Model.create(attachment, response.form(res, formName))
});

router.get('/get', function (req, res, next) {
	var id = mongoose.Types.ObjectId(req.body.id);
	Model.findOne({ _id: id }, response.form(res, formName, Errors.InvalidUserId))
});

router.get('/target', function(req, res, next) {
	var params = req.body;

	var conditions 	= { 
		_id 		 : mongoose.Types.ObjectId(params.id),
		owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
		status 		 : 'active',
		mark_deleted : false
	};
	var update 		= {
		target_id : mongoose.Types.ObjectId(params.target_id)
	};
	var options 	= { 'new' : true};

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.get('/list/scope', function(req, res, next) {
	var params 		= req.body;
	var ids 		= params.ids;
	var owner_id 	= mongoose.Types.ObjectId(params.owner_id);

	ids = _.map(ids, function(id){ return mongoose.Types.ObjectId(id)});

	var conditions 	= { _id : { $in : ids}, owner_id: owner_id};
	var update  	= { target_id : mongoose.Types.ObjectId(params.target_id)};
	var options 	= { multi: true };

	Model.update(conditions, update, options, response.ok(res))
});

//список аттачей ответа
router.get('/list/target', listTransform(mongoose, { sort : { created_at : -1 }, limit : 5 }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			//owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
			status 		 : 'active',
			target_id 	 : mongoose.Types.ObjectId(params.target_id),
			mark_deleted : false
		}		
	};

	req.list_aggregate.unshift(conditions);	
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//вернуть список аттачей пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : 5 }), function (req, res, next) {
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

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.use(errorHandler);

module.exports = router;
var _ 					= require('underscore');
var Router 				= require('./router');
var serialize 			= require('gt-serialize');
var response 			= require('gt-response');
var Error 				= require('gt-error');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/answer');
var schemaObjectId  	= require('./schemas/objectId');
var schemaEvent 		= require('./schemas/event');
var errorHandler 		= require('gt-error-handling');
var validator 			= require('./validatorParameters');
var listTransform 		= require('gt-list');
var helper 				= require('./helper');

var Model 		= mongoose.model('Answer', schema);
var Event 		= mongoose.model('Event', schemaEvent);
var ObjectId 	= mongoose.model('ObjectId', schemaObjectId);
var formName 	= "answer";
var limit 		= 6;
var router 		= new Router();

router.get('/create', function (req, res, next) {
	var params = req.body;

	//проверить event существует и активен
	var event_id = mongoose.Types.ObjectId(params.event_id);
	var owner_id = mongoose.Types.ObjectId(params.owner_id);

	Event.findOne({ _id : event_id}, function(err, event) {
		if (err) {
			response.error(res, Errors.InternalServiceError, err.errmsg);
		} else {
			if (event) {
				var conditions = {
					owner_id 		: owner_id,
					event_id 		: event_id,
					mark_deleted 	: false
				};

				var data = _.pick(params, 'event_id', 'description', 'status', 'owner_id', 'loc', 'localized_loc');

				data.owner_id  			= owner_id;
				data.event_id  			= event_id;
				data.event_context  	= event.criteria.context;
				data.event_created_at 	= event.created_at;
				data.canceled_at 		= event.canceled_at;

				Model.findOne(conditions, function(error, answer){
					if (err) {
						response.error(res, Errors.InternalServiceError, err.errmsg);
					} else {
						if (answer == null) {
							//создаем новый ответ
							ObjectId.create({
								type: 'answer'
							}, function(err, objectid) {
								if (err) {
									response.error(res, Errors.InternalServiceError, err.errmsg);
								} else {
									data.object_id = mongoose.Types.ObjectId(objectid._id);
									Model.create(data, response.form(res, formName));
								}
							});
						} else {
							//обновляем старый, обноляем только статус
							_.extend(answer, data);
							answer.save(response.form(res, formName))
						}
					}
				});
			} else {
				response.error(res, Errors.NotFound);
			}
		}
	});


});

router.get('/update', function(req, res, next) {
	var params = _.pick(req.body, 'status', 'description', 'id', 'owner_id');
	var conditions = {
		_id 			: mongoose.Types.ObjectId(params.id),
		owner_id 		: mongoose.Types.ObjectId(params.owner_id),
		mark_deleted 	: false
	};
	var update = {
		description 	: params.description,
		status  		: params.status
	};
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.get('/get', function(req, res, next) {
	var id = req.body.id;
	var conditions =  {
		_id 			: mongoose.Types.ObjectId(id),
		mark_deleted 	: false
	};

	Model.findOne(conditions, response.form(res, formName))
});

router.get('/is', function(req, res, next) {
	var conditions = {
		owner_id 		: mongoose.Types.ObjectId(req.body.owner_id),
		event_id 		: mongoose.Types.ObjectId(req.body.event_id),
		mark_deleted 	: false
	};

	Model.findOne(conditions, response.form(res, formName))
});

router.get('/is/ids', function(req, res, next) {
	var ids = req.body.ids;

	if (!Array.isArray(ids)) {
		response.error(res, Errors.InternalServiceError);
	} else {
		ids = _.map(ids, function(id){ return mongoose.Types.ObjectId(id)});

		var conditions = {
			owner_id 		: mongoose.Types.ObjectId(req.body.owner_id),
			event_id 		: {
				$in : ids
			},
			mark_deleted 	: false
		};

		Model.find(conditions, response.list(res, req))
	}

});

//вернуть списоком
router.get('/ids', function (req, res, next) {
	var params 	= req.body;
	var ids 	= params.ids;

	if (!Array.isArray(ids)) {
		response.error(res, Errors.InternalServiceError);
	} else {
		ids = _.map(ids, function(id){ return mongoose.Types.ObjectId(id)});
		Model.find({ _id : {$in : ids}}, response.list(res, req))
	}
});

router.get('/delete', function(req, res, next) {
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

//список ответов пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id 		: mongoose.Types.ObjectId(params.owner_id),
			mark_deleted 	: false
		}		
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req));
});

//список ответов пользователя
//лента
router.get('/list/perform', listTransform(mongoose, { sort : { event_created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var context = ["7", "3", "2", "4"];
	var conditions = {
		'$match' : {
			owner_id 		: mongoose.Types.ObjectId(params.owner_id),
			canceled_at     : {
				$gt : helper.dateNow()
			},
			event_context 	: { "$in" : context},
			mark_deleted 	: false
		}		
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//
router.get('/scope/cancel', function(req, res, next) {
	var conditions = {
		event_id 	: mongoose.Types.ObjectId(req.body.target_id)
		//status 	: 'accepted'
	};

	var update = {
		canceled_at: helper.dateNow()
	};

	var options = { multi: true };
	Model.update(conditions, update, options, response.ok(res));
});

//список ответов события, только те которые положительно ответили
router.get('/list/event', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			event_id 	: mongoose.Types.ObjectId(params.event_id),
			status 		: 'accepted',
			mark_deleted: false	
		}		
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

router.use(errorHandler);

module.exports = router;
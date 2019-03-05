var _ 					= require('underscore');
var Router 				= require('./router');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/event');
var schemaObjectId  	= require('./schemas/objectId');
var errorHandler 		= require('gt-error-handling');
var validator 			= require('./validatorParameters');
var response 			= require('gt-response');
var listTransform 		= require('gt-list');
var helper 				= require('./helper');


var Model 		= mongoose.model('Event', schema);
var ObjectId 	= mongoose.model('ObjectId', schemaObjectId);
var formName 	= "event";
var limit  		= 6;
var router 		= new Router();

router.get('/create', function (req, res, next) {
	var params = req.body;
	
    ObjectId.create({
    	type: 'event'
    }, function(err, objectid) {
    	if (err) {
			response.error(res, Errors.InternalServiceError, err.errmsg);
        } else {
	    	var data = _.pick(params, 'owner_id', 'description', 'allow_phone', 'allow_email', 'criteria', 'loc', 'localized_loc');

	    	data.owner_id  = mongoose.Types.ObjectId(data.owner_id);
	    	data.object_id = mongoose.Types.ObjectId(objectid._id);
	    	data.status 	= 'active';
	    	data.meta 		= {
	    		comments 	: 0,
	    		favs 		: 0
	    	};
			data.visible_map_at = helper.calculateVisibleMap(data);
	    	data.canceled_at 	= helper.calculateCanceledTime(data);

		    Model.create(data, response.form(res, formName));
		}
    });	
});

router.get('/update', function(req, res, next) {
	var conditions = {
		_id 			: mongoose.Types.ObjectId(req.body.event_id),
		owner_id 		: mongoose.Types.ObjectId(req.body.owner_id),
		mark_deleted 	: false
	};
	var update = {
		description : req.body.description
	};
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.get('/get', function(req, res, next) {
	var id = req.body.id;

	Model.findOne({ 
		_id 			: mongoose.Types.ObjectId(id),
		mark_deleted 	: false
	}, response.form(res, formName))
});

//добавить в избранное
router.get('/favorite', function(req, res, next) {
	var id = req.body.id;

	Model.findOne({
		_id 			: mongoose.Types.ObjectId(id),
		mark_deleted 	: false
	}, response.form(res, formName))
});

router.get('/angry', function(req, res, next) {
	var id = req.body.id;

	Model.findOne({
		_id 			: mongoose.Types.ObjectId(id),
		mark_deleted 	: false
	}, response.form(res, formName))
});

router.get('/delete', function(req, res, next) {
	var conditions = {
		_id 	: mongoose.Types.ObjectId(req.body.event_id),
		owner_id: mongoose.Types.ObjectId(req.body.owner_id)
	};
	var update = {
		mark_deleted : true
	};
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

//список ближайщих событий
router.get('/list/near', function(req, res, next) {
	var params 		= req.body;
	var center		= helper.parseGeoCoordinates(params.loc);
	var distance 	= helper.parseGeoDistance(params);
	var owner_id    = mongoose.Types.ObjectId(params.owner_id);

	Model.aggregate([
		{
			"$geoNear": {
		        near 				: center,
		        maxDistance 		: helper.getGeoMaxDistance(distance), 
		        distanceMultiplier 	: helper.getGeoDistanceMultiplier(),
		        num 				: 10,
		        query 				: {
		        	status 		 : 'active',
		        	mark_deleted : false,
		        	owner_id 	 : {
		        		"$ne" : owner_id
		        	},
					//удалить запросы с context
					//
		        	visible_map_at :  {
		        		"$gt" : helper.dateNow()
		        	}
		        },
		        uniqueDocs 			: true,
		        distanceField 		: 'distance',
		        spherical 			: true
     		}	
     	},
     	{ "$skip" 	: 0 },
    	{ "$limit" 	: 10 }//минимальное количество
	]).exec(response.list(res, req))
});

router.get('/list/missed', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var conditions = {
		"$match" : {
			mark_deleted : false
		}		
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//архив
router.get('/list/filter', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params 		= req.body;
	var from 		= params.from ? new Date(params.from) : helper.fromArchive();
	var to 			= params.to ? new Date(params.to) : helper.toArchive();

	var conditionsMatch = { 
		"$match" : {
			$and: [
				{created_at   : { "$gte" : from, "$lte": to}}, //ранже времни
				{mark_deleted : false} //неудаленные
			],
			$or : [
				{ status: 'canceled' },
				{ canceled_at: { $lt: helper.dateNow() }}
			]
		}
	};

	//убрать найди меня
	//боюсь идти одна
	var context = params.context? [params.context]: ["3", "1", "7", "2"];
	req.list_aggregate.unshift({
		"$match" : {
			"criteria.context" : { "$in" : context}
		}
	});

	req.list_aggregate.unshift(conditionsMatch);

	if (params.loc) {
		var center		= helper.parseGeoCoordinates(params.loc);
		var distance 	= helper.parseGeoDistance(params);
		var query 		= helper.convertListAggregateToQuery(req.list_aggregate);

		//место
		var conditionGeo = {
			"$geoNear": {
		        near 				: center,
		        maxDistance 		: helper.getGeoMaxDistance(distance), 
				distanceMultiplier 	: helper.getGeoDistanceMultiplier(),//метров в радиане
		        num 				: query.limit,//сюда limit
				query 				: query.match,//$match
		        uniqueDocs 			: true,
		        distanceField 		: 'distance',
		        spherical 			: true
			}	
		};

		req.list_aggregate = [conditionGeo, { "$sort": { "created_at": -1 } }];
		req.list_aggregate.$limit = query.limit;
	}

	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//очевидцы
router.get('/list/spectator', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params 		= req.body;
	var event_id 	= params.id;

	Model.findOne({
		_id 			: mongoose.Types.ObjectId(event_id),
		mark_deleted 	: false
	}, function(err, event) {
		if (err) {
			response.error(res, Errors.InternalServerError)
		} else {

			if (!helper.eventWithSpectators(event))
				return response.error(res, Errors.InternalServerError);


			var from = helper.fromSpectator(event);
			var to 	 = helper.toSpectator(event);
			var subtype = helper.subtypeSpectator(event);
			var context = ["1"];

			var conditionsMatch = {
				"$match" : {
					owner_id		: { "$ne" : event.owner_id},
					created_at   	: { "$gte" : from, "$lte": to}, //ранже времн
					status 			: 'active',
					mark_deleted 	: false,
					"criteria.context" : { "$in" : context},
					"criteria.subtype" : { "$in" : subtype}
				}
			};

			req.list_aggregate.unshift(conditionsMatch);

			var center		= helper.parseGeoCoordinates(event.loc);
			var distance 	= helper.getGeoMaxDistanceFormFindSpectator(event);
			var query 		= helper.convertListAggregateToQuery(req.list_aggregate);

			//место
			var conditionGeo = {
				"$geoNear": {
					near 				: center,
					maxDistance 		: helper.getGeoMaxDistance(distance),
					distanceMultiplier 	: helper.getGeoDistanceMultiplier(),//метров в радиане
					num 				: query.limit,//сюда limit
					query 				: query.match,//$match
					uniqueDocs 			: true,
					distanceField 		: 'distance',
					spherical 			: true
				}
			};

			req.list_aggregate = [conditionGeo, { "$sort": { "distance": -1 } }];
			req.list_aggregate.$limit = query.limit;

			console.log(req.list_aggregate[0]["$geoNear"].query);
			Model.aggregate(req.list_aggregate).exec(response.list(res, req))
		}
	});
});

//список событий пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
			mark_deleted : false,
			status 		 : 'active'
		}		
	};

	req.list_aggregate.unshift(conditions);

	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//список событий пользователя
router.get('/list/active', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
			mark_deleted : false,
			status 		 : 'active',
			canceled_at  : { $gte: helper.dateNow() }
		}
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

//список событий пользователя
router.get('/list/canceled', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			$and : [
				{
					owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
					mark_deleted : false
				}
			],
			$or : [
				{ status: 'canceled' },
				{ canceled_at: { $lt: helper.dateNow() }}
			]
		}
	};

	req.list_aggregate.unshift(conditions);
	Model.aggregate(req.list_aggregate).exec(response.list(res, req))
});

router.get('/list/favorites', listTransform(mongoose, { sort : { created_at : -1 }, limit : limit }), function(req, res, next) {
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



//список похожих
router.get('/list/similar', function(req, res, next) {

});

//список событий входящих в полигон
//для поиска по городу
router.get('/list/polygon', function(req, res, next) {

});

//отбой
//разрешено владльцем
router.get('/cancel', function(req, res, next) {
	var conditions = {
		_id 			: mongoose.Types.ObjectId(req.body.id),
		owner_id 		: mongoose.Types.ObjectId(req.body.owner_id),
		mark_deleted 	: false
	};
	var update = {
		status 		: 'canceled',
		canceled_at : helper.dateNow()
	};
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

//отбой
//разрешено владльцем
router.get('/remove', function(req, res, next) {
	var conditions = {
		_id 			: mongoose.Types.ObjectId(req.body.id),
		owner_id 		: mongoose.Types.ObjectId(req.body.owner_id)
	};
	var update = {
		mark_deleted : true
	};
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
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

//сделать активным 
//разрешено только владельцам
router.get('/active', function(req, res, next) {
	var conditions = {
		_id 			: mongoose.Types.ObjectId(req.body.event_id),
		owner_id 		: mongoose.Types.ObjectId(req.body.owner_id),
		mark_deleted 	: false
	};
	var update = {
		status : 'active'
	};
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.use(errorHandler);

module.exports = router;
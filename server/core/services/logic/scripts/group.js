var _ 					= require('underscore');
var Router 				= require('./router');
var serialize 			= require('gt-serialize');
var Error 				= require('gt-error');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/group');
var schemaObjectId  	= require('./schemas/objectId');
var errorHandler 		= require('gt-error-handling');
var validator 			= require('./validatorParameters');
var listTransform 		= require('gt-list');
var helper 				= require('./helper');


var Model 		= mongoose.model('Group', schema);
var ObjectId 	= mongoose.model('ObjectId', schemaObjectId);

var router 		= new Router();

//добавить проверку кто может создавать группы
router.get('/create', function (req, res, next) {
	var params = req.body;
	
    ObjectId.create({
    	type: 'group'
    }, function(err, objectid) {
    	if (err) {
        	res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
        } else {
	    	var data = _.pick(params, 'owner_id', 'description', 'title');

	    	data.owner_id  	= mongoose.Types.ObjectId(data.owner_id);
	    	data.object_id 	= mongoose.Types.ObjectId(objectid._id);
	    	data.status 	= 'open';
	    	
		    Model.create(data, function(err, data) {
				if (err) {
					res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
				} else {
					if (data) {
						res.send(serialize.success({
							group : data
						}))	
					} else {
						res.send(serialize.error(new Error(Errors.NotFound)));
					}
					
				}		
			})	
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
	}

	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, function(err, data) {
		if (err) {
			res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
		} else {
			res.send(serialize.success({
				group : data
			}))
		}		
	}) 
});

router.get('/get', function(req, res, next) {
	var id = req.body.id;

	Model.findOne({ 
		_id 			: mongoose.Types.ObjectId(id),
		mark_deleted 	: false
	}, function (err, data) {
        if (err) {
        	res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
        } else {
        	if (data) {
				res.send(serialize.success({
	        		group: data
	        	}))
        	} else {
        		res.send(serialize.error(new Error(Errors.NotFound)));			
        	}
        	
        }
      })
});

router.get('/delete', function(req, res, next) {
	var conditions = {
		_id 	: mongoose.Types.ObjectId(req.body.event_id),
		owner_id: mongoose.Types.ObjectId(req.body.owner_id)
	};
	var update = {
		mark_deleted : true
	}
	var options = { 'new' : true };

	Model.findOneAndUpdate(conditions, update, options, function(err, data) {
		if (err) {
			res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
		} else {
			res.send(serialize.success({
				group : data
			}))
		}		
	}) 
});

//вернуть списоком
router.get('/ids', function (req, res, next) {
	var params 	= req.body;
	var ids 	= params.ids;

	if (!Array.isArray(ids)) {
		return res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
	}

	ids = _.map(ids, function(id){ return mongoose.Types.ObjectId(id)});

	Model.find({ _id : {$in : ids}}, function(err, result) {
		if (err) {
			res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
		} else {
			res.send(serialize.list(result))
		}
	})
});

router.use(errorHandler);

module.exports = router;
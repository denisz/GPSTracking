var _ 					= require('underscore');
var Router 				= require('./router');
var serialize 			= require('gt-serialize');
var Error 				= require('gt-error');
var Errors 				= require('gt-errors');
var mongoose 			= require('mongoose');
var schema  			= require('./schemas/follower');
var schemaGroup  		= require('./schemas/group');
var errorHandler 		= require('gt-error-handling');
var validator 			= require('./validatorParameters');
var listTransform 		= require('gt-list');
var helper 				= require('./helper');


var Model 		= mongoose.model('Follower', schema);
var Group 		= mongoose.model('Group', schemaGroup);
var router 		= new Router();

router.get('/create', function (req, res, next) {
	var params = req.body;
	
	var data = _.pick(params, 'owner_id', 'target_id');

	data.user_id    = mongoose.Types.ObjectId(data.owner_id);
	data.target_id  = mongoose.Types.ObjectId(data.target_id);

	//проверить что данная группа есть и можно в неё вступить	
	Group.findOne({
		_id: mongoose.Types.ObjectId(data.target_id)
	}}, update, options, function(err, group) {
		if (err) {
			res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
		} else {
			if (group.status == "open") {
				Model.create(data, function(err, data) {
					if (err) {
						res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
					} else {
						if (data) {
							res.send(serialize.success({
								follower : data
							}))	
						} else {
							res.send(serialize.error(new Error(Errors.NotFound)));
						}					
					}		
				})
			} else {
				res.send(serialize.error(new Error(Errors.NotFound)));
			}				
		}		
	}) 
       
});

router.get('/is', function(req, res, next) {
	var id = req.body.id;

	Model.findOne({ 
		_id : mongoose.Types.ObjectId(id)
	}, function (err, data) {
        if (err) {
        	res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
        } else {
        	if (data) {
				res.send(serialize.success({
	        		follower: data
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
	
	Model.findOneAndRemove(conditions, function(err, data) {
		if (err) {
			res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
		} else {
			res.send(serialize.success({
				follower : data
			}))
		}		
	}) 
});

//список групп пользователя
router.get('/list/user', listTransform(mongoose, { sort : { created_at : -1 }, limit : 5 }), function(req, res, next) {
	var params = req.body;
	var conditions = {
		'$match' : {
			owner_id 	 : mongoose.Types.ObjectId(params.owner_id),
		}		
	};

	req.list_aggregate.unshift(conditions);

	Model.aggregate(req.list_aggregate).exec(function(err, result){
		if (err) {
			res.send(serialize.error(new Error(Errors.InternalServiceError, err.errmsg)));			
		} else {
			res.send(serialize.list(result, req.list_aggregate))
		}
	})	
})

router.use(errorHandler);

module.exports = router;
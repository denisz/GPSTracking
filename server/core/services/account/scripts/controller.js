var _ = require('underscore');

var Router 				= require('./router');
var Errors 				= require('gt-errors');
var expressValidator 	= require('express-validator');
var mongoose 			= require('mongoose');
var validator  			= require('gt-validator');
var rules  				= require('./validator');
var UserSchema  		= require('./schemas/user');
var passwordHash 		= require('password-hash');
var errorHandler 		= require('gt-error-handling');
var uuid 				= require('uuid');
var response 			= require('gt-response');
var social 				= require('./social');
var helper 				= require('./helper');

var Model 	= mongoose.model('User', UserSchema);
var router 	= new Router();

var formName = "user";

router.use(expressValidator());

//login
router.get('/login', validator(rules, 'login'), function(req, res, next) {
	var params 	= req.body;

	Model.findOne({ email: params.email }, function(err, data) {
		if (err) {
			response.error(res, Errors.UserAuthorizationFailed);
		} else {
			if (data) {
				if (passwordHash.verify(params.password, data.passwordHash)) {
					response.user(res, formName)(err, data);
				} else {
					response.error(res, Errors.UserAuthorizationFailed);
				}
				
			} else {
				response.error(res, Errors.UserAuthorizationFailed);
			}
		}

	})
});	

//get
router.get('/get', function (req, res, next) {
	var user_id = mongoose.Types.ObjectId(req.body.id);
	Model.findOne({ _id: user_id }, response.form(res, formName, Errors.InvalidUserId))
});

//ids
router.get('/ids', function (req, res, next) {
	var params 	= req.body;
	var ids 	= params.ids;

	if (!Array.isArray(ids)) {
		response.error(res, Errors.InternalServiceError);
	} else {
		ids = _.map(ids, function(id){ return mongoose.Types.ObjectId(id)});
		Model.find({ _id : {$in : ids}},  response.list(res, req))
	}

});

//обновить
router.get('/update', function (req, res, next) {
	var params = req.body;

	var conditions 	= { _id : mongoose.Types.ObjectId(params.user_id) };
	var update 		= _.pick(params, ['email', 'password', 'fullname', 'phone', 'avatar', 'cover', 'settings']);
	var options 	= {'new': true};

	if (update.hasOwnProperty("password")) {
		update.password = passwordHash.generate(update.password);
	}

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

//добавить права
router.get('/changeStatus', function (req, res, next) {
	var params = req.body;

	var conditions 	= { _id : mongoose.Types.ObjectId(params.user_id) };
	var update 		= {
		status : params.status
	};
	var options 	= { 'new' : true};

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

//
router.get('/phone', function (req, res, next) {
	var params = req.body;
	var phone  = helper.normalizePhone(params.phone);

	if (phone) {
//		a.substring(a.length - 10)
		var conditions 	= { phone : phone };
		Model.findOne(conditions, response.form(res, formName))
	} else {
		response.error(res, Errors.UserAuthorizationFailed);
	}
});

router.get('/register', validator(rules, 'register'), function(req, res, next) {
	var params 			= req.body;
	var hashedPassword 	= passwordHash.generate(params.password);
	
	Model.create({ 
		email 			: params.email, 
		passwordHash 	: hashedPassword, 
		fullname 		: params.fullname,
		role 			: 'user'
	}, response.user(res, formName));		
});

router.get('/social/fb', validator(rules, 'social'), function (req, res, next) {
	var accessToken = req.body.access_token;
	
	social.FB.auth(accessToken)
		.then(function(fbUser) {
			var objSocial = helper.structFBSocial(fbUser);

			Model.findOne({ social: { $contains: [ objSocial ]}}, function(err, model) {
				if (err) {
					response.error(res, Errors.InternalServiceError);
				} else {
					if (model) {
						//логин
						response.form(res, formName)(err, model);
					} else {
						//регистрация
						Model.create(helper.convertFBToUser(fbUser), response.user(res, formName));
					}
				}
			})
		})
		.fail(function(result) {
			response.error(res, Errors.UserAuthorizationFailed);
		});
});

router.get('/link/fb', validator(rules, 'social'), function (req, res, next) {
	var accessToken = req.body.access_token;
	var owner_id = req.body.owner_id;

	social.FB.auth(accessToken)
		.then(function(fbUser) {
			var objSocial = helper.structFBSocial(fbUser);

			Model.findOne({ social: { $contains: [ objSocial ]}}, function(err, model) {
				if (err) {
					response.error(res, Errors.InternalServiceError);
				} else {
					if (model) {
						//уже залинкован //вернуть модель
						response.form(res, formName)(err, model);
					} else {
						//залинкуем
						Model.findOne({ _id: owner_id }, function(err, model) {
							if (err) {
								response.error(res, Errors.InternalServiceError);
							} else {
								if (model) {
									model.social.push(objSocial);
									model.save(response.form(res, formName));
								} else {
									response.error(res, Errors.NotFound);
								}
							}
						});
					}
				}
			})
		})
		.fail(function(result) {
			response.error(res, Errors.UserAuthorizationFailed);
		});
});

router.get('/update', function(req, res, next) {

});

router.get('/changepwd', function(req, res, next){
	var hash 			= req.body.hash;
	var newpassword 	= req.body.newpassword;
	var email 			= req.body.email;
	var hashedPassword 	= passwordHash.generate(newpassword);
	var options 	= { 'new': true };
	var conditions	= {
		email 				: email,
		password_reset_hash : hash
	};
	var update  = {
		passwordHash 		: hashedPassword,
		password_reset_hash : null
	};

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.get('/resetpswd', function(req, res, next){
	var email 		= req.body.email;
	var hash  		= uuid();
	var conditions 	= { email: email };
	var update  	= { password_reset_hash: hash};
	var options 	= { 'new': true };

	Model.findOneAndUpdate(conditions, update, options, response.form(res, formName))
});

router.get('/list/all', function (req, res, next){
	Model.find({}, response.list(res, req));
});

router.use(errorHandler);

module.exports = router;
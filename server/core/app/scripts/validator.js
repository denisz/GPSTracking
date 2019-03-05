module.exports = {
	'account/login' : {
		'email' : function (req) { 
			req.checkBody('email', 'required').notEmpty();
			req.checkBody('email', 'valid email required').isEmail();
		},
		'password' : function (req) {
			req.checkBody('password', '6 to 20 characters required').len(6, 20);
		}
	},
	'account/register' : {
		'fullname' : function (req) {
			req.checkBody('fullname', 'required').notEmpty();
		},
		'email' : function (req) { 
			req.checkBody('email', 'required').notEmpty();
			req.checkBody('email', 'valid email required').isEmail();
		},
		'password' : function (req) {
			req.checkBody('password', 'required').notEmpty();
			req.checkBody('password', '6 to 20 characters required').len(6, 20);
		}	
	},
	'account/social/fb' : {
		'access_token': function(req) {
			req.checkBody('access_token', 'required').notEmpty();
		}
	},
	'user/update' : {
		'fullname' : function (req) {
			req.checkBody('fullname', 'required').notEmpty();
		},
		'email' : function (req) { 
			req.checkBody('email', 'required').notEmpty();
			req.checkBody('email', 'valid email required').isEmail();
		}
	},
	'session/apn': {
		'device_token' : function (req) {
			req.checkBody('device_token', 'required').notEmpty();
		}
	},
	'session/gcm': {
		'device_token' : function (req) {
			req.checkBody('device_token', 'required').notEmpty();
		}
	},
	'event/create' : {

	},	
	'event/update' : {

	},
	'answer/create' : {
		'event_id': function(req) {
			req.checkBody('event_id', 'required').notEmpty();
		}
	},
	'answer/update' : {

	},
	'comment/create' : {

	},
	'favorite/create': {
		'target_id': function(req) {
			req.checkBody('target_id', 'required').notEmpty();
		}
	},
	'account/changepwd' : {
		'email' : function (req) {
			req.checkBody('email', 'required').notEmpty();
			req.checkBody('email', 'valid email required').isEmail();
		},
		'hash': function(req){
			req.checkBody('hash', 'required').notEmpty();	
		},
		'newpassword': function () {
			req.checkBody('newpassword', 'required').notEmpty();
			req.checkBody('newpassword', '6 to 20 characters required').len(6, 20);
		}
	},
	'account/resetpswd' : {
		'email' : function (req) {
			req.checkBody('email', 'required').notEmpty();
			req.checkBody('email', 'valid email required').isEmail();
		}
	},
	'account/update' : {
		'fullname' : function (req) {
			req.checkBody('fullname', 'required').notEmpty();
		},
		'email' : function (req) { 
			req.checkBody('email', 'valid email').isEmail();
		},
		'password' : function (req) {
			req.checkBody('password', '6 to 20 characters required').len(6, 20);
		}	
	},
	'checkin/create' : {
		'loc' : function(req){
			req.checkBody('loc', 'required').notEmpty();
		}
	}
};

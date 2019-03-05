module.exports = {
	'login' : {
		'email' : function (req) { 
			req.checkBody('email', 'required').notEmpty();
		},
		'password' : function (req) {
			req.checkBody('password', 'required').notEmpty();
		}
	},
	'register' : {
		'fullname' : function (req) {
			req.checkBody('fullname', 'required').notEmpty();
		},
		'email' : function (req) { 
			req.checkBody('email', 'required').notEmpty();
		},
		'password' : function (req) {
			req.checkBody('password', 'required').notEmpty();
		}	
	}
};

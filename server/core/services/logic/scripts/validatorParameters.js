var Error 	= require('gt-error');
var Errors 	= require('gt-errors');
var rules 	= require('./validator');

var ValidatorParameters = function (form) {
	return function (req, res, next) {
		var fields = rules[form];

		if (fields) {
			for(var i in fields) {
				fields[i](req);
			}

			var errors = req.validationErrors(true);

			if (errors) {
				throw new Error(Errors.InvalidParameters, errors);
			}
		}

		next();	
	};	
};

module.exports = ValidatorParameters;
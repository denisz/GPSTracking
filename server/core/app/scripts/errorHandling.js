var Serialize 	= require('gt-serialize');
var Errors 		= require('gt-errors');
var Error 		= require('gt-error');

var ErrorHandling = function (err, req, res, next) {
	var result = Serialize.error(err);
	res.json(result);
	//next(err);
};

module.exports = ErrorHandling;
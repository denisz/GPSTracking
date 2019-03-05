var RequireAccess = function (access) {
	return function (req, res, next) {
		next();
	}
};

module.exports = RequireAccess;
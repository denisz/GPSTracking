var LoadUser = function (req, res, next) {
	var driver = req.app.get('driver');

	driver.command('account/get', {id : req.session.user_id})
		.then(function(dataUser) {
			req.user = dataUser.user;
			next();
		})
		.fail(function(data) {
			res.json(serialize.error(data));
		})
};

module.exports = LoadUser;
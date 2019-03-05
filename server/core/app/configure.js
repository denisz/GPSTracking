var config  = require('./config');

module.exports = function (app, env) {
	var configEnv;

	env 		= env || app.get('env');
	configEnv 	= config[env] || {};

	for (var i in configEnv) {
		app.set(i, configEnv[i]);
	}
};
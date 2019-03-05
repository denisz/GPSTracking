var gulp 		= require('gulp');
var chalk 		= require('chalk');
var server 		= require('gulp-express');
var _ 			= require('underscore'); 

var preprocess  = function(obj) {
	_.extend(process.env, obj.context);
};

var ENV = {
	DEV  : 'development',
	PROD : 'production'
};

var devServices = {
	'app' : {
		port 		: 3000,
		entryPoint 	: "app.js"
	},
	'auth' : {
		port 		: 3002,
		entryPoint 	: "core/services/auth/app.js"
	},
	'account' : {
		port 		: 3001,
		entryPoint 	: "core/services/account/app.js"
	},
	'logic' : {
		port 		: 3003,
		entryPoint 	: "core/services/logic/app.js"	
	},
	'checkin' : {
		port 		: 3004,
		entryPoint 	: "core/services/checkin/app.js"	
	},
	'notification' : {
		port 		: 3005,
		entryPoint 	: "notification.js"	
	}
};

var prodServices = {
	'app' : {
		port 		: 8000,
		entryPoint 	: "app.js"
	},
	'auth' : {
		port 		: 8002,
		entryPoint 	: "core/services/auth/app.js"
	},
	'account' : {
		port 		: 8001,
		entryPoint 	: "core/services/account/app.js"
	},
	'logic' : {
		port 		: 8003,
		entryPoint 	: "core/services/logic/app.js"	
	},
	'checkin' : {
		port 		: 8004,
		entryPoint 	: "core/services/checkin/app.js"	
	},
	'notification' : {
		port 		: 8005,
		entryPoint 	: "notification.js"
	}
}

var getServiceOptions = function (env) {
	switch(env) {
		case ENV.DEV:
			return devServices;
			break;
		case ENV.PROD:
			return prodServices;
			break;
	}
};

var service = function (serviceNamed) {
	var env 			= process.env.NODE_ENV;
	var options 		= {};
	var serviceOptions 	= getServiceOptions(env)[serviceNamed];

	options.env 			= process.env;
	options.env.PORT 		= serviceOptions.port;

	try{
		server.run([ serviceOptions.entryPoint ], options, false);	
	}catch(e) {
		console.error(e);
	}
	
};

var setDevOptions = function () {
	preprocess({ 
		context 	: {
			DEBUG 		: false,
//			DEBUG 		: 'amqp-rpc',
			//NODE_DEBUG_AMQP:true,
			NODE_ENV 	: ENV.DEV
		}
	});
};

var setProdOptions = function () {
	preprocess({ 
		context 	: { 
			DEBUG 		: false,
			NODE_ENV 	: ENV.PROD
		}
	});
};

var getServices = function (modules) {
	var services = _.keys(devServices).map(function(v){ return "service:" + v});
	return modules.concat(services);
};

//enviroment
gulp.task('dev', getServices(['options:dev', 'service:app']), function() {
	console.log(chalk.grey("Rabbitmq managment ")  + chalk.red("http://127.0.0.1:15672/"));
});

gulp.task('prod', getServices(['options:prod', 'service:app']), function() {
	console.log(chalk.grey("Rabbitmq managment ")  + chalk.red("http://127.0.0.1:15672/"));
});

gulp.task('build', function() {

});

//options
gulp.task('options:dev', 	setDevOptions);
gulp.task('options:prod', 	setProdOptions);

//services
gulp.task('app', ['options:dev', 'service:app'], function () {
	console.log(chalk.grey("Rabbitmq managment ")  + chalk.red("http://127.0.0.1:15672/"));
});

gulp.task('account', ['options:dev', 'service:account'], function () {
	
});

gulp.task('auth', ['options:dev', 'service:auth'], function () {

});

gulp.task('logic', ['options:dev', 'service:logic'], function () {

});

gulp.task('checkin', ['options:dev', 'service:checkin'], function () {

});

gulp.task('notify', ['options:dev', 'service:notification'], function () {

});


/**************/
gulp.task('service:app', function () {
	service('app');	
});

gulp.task('service:account', function () {
	service('account');	
});

gulp.task('service:auth', function() {
	service('auth');
});

gulp.task('service:logic', function() {
	service('logic');
});

gulp.task('service:checkin', function() {
	service('checkin');
});

gulp.task('service:notification', function(){
	service('notification');
});
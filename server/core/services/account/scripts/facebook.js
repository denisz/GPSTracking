var graph = require('fbgraph');
var Q = require('q');
// extending static access token

var APP_ID 		= "487535111394371";
var APP_SECRET 	= "aef94377b937a940acb5d76b96c1ac91";

graph.setAppSecret(APP_SECRET);
//graph.setVersion('2.1');

module.exports = {
	auth : function(access_token) {
		var _deferred = Q.defer();
		graph.setAccessToken(access_token);
		graph.get('me', function(err, res) {
			  if (err != null) {
				_deferred.reject(err);	
	    	} else {
	    		_deferred.resolve(res);	
	    	}	       	
		});

		return _deferred.promise;
	},

	user : function (uid) {
		var _deferred = Q.defer();
		
		graph.get(uid, function(err, res) {
			  if (err != null) {
				_deferred.reject(err);	
	    	} else {
	    		_deferred.resolve(res);	
	    	}	       	
		});

		return _deferred.promise;

	},

	setAccessToken : function (access_token) {
		graph.setAccessToken(access_token);
	}
}
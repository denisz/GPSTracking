var Router 				= require('./router');
var serialize 			= require('gt-serialize');
var response 			= require('gt-response');
var Errors 				= require('gt-errors');
var errorHandler 		= require('gt-error-handling');

var router 	= new Router();
var formName = "checkin";

router.get('/create', function(req, res, next) {
	var cache 	= req.app.get('cache');
	var params 	= req.body;
	var lat 	= params.latitude;
	var lon 	= params.longitude;

	cache.create(lat, lon, params.id, response.ok());
});

router.get('/get', function(req, res, next) {
	var cache 		= req.app.get('cache');
	var owner_id 	= req.body.id;
	
	cache.get(owner_id, response.form(res, formName));
});

router.get('/list/near', function(req, res, next) {
	var cache 		= req.app.get('cache');
	var type 		= req.body.type;
	var center 		= req.body.coordinates;
	var distance 	= req.body.distance || 200;

	//сделать лимит
	cache.nearby(center.lat, center.lon, distance, response.list(res, req))
});

router.use(errorHandler);

module.exports = router;
var _ = require('underscore');
var Router 					= require('../scripts/router');
var serialize 				= require('gt-serialize');
var errorHandling 			= require('gt-error-handling');
var rules 					= require('../scripts/validator');
var validator  			 	= require('gt-validator');
var requireAuthentication 	= require('../scripts/requireAuthentication');
var requireAccess 			= require('../scripts/requireAccess');
var thumbnail 				= require('gt-thumbnail').thumb;
var multer  				= require('multer');
var crypto 					= require('crypto');

var router = new Router();

router.post('/image', requireAuthentication, multer({
	dest: './uploads/',
	limits: {
		fieldNameSize 	: 100,
		files 			: 1
	},
	onFileUploadStart: function (file, req, res) {
		if (file.mimetype !== 'image/png' && file.mimetype !== 'image/jpeg') {
			return false;
		}
	},
	onFileUploadData: function (file, data, req, res) {},
	onFileUploadComplete: function (file, req, res) {},
	onError: function (error, next) {
		next(error)
	},
	rename: function (fieldname, filename, req, res) {
		var user_id = req.session.user_id;
		var random_string = fieldname + filename + Date.now() + Math.random();
		return user_id + "_" + crypto.createHash('md5').update(random_string).digest('hex');
	}
}), thumbnail('uploads/'), function (req, res, next) {
	var driver 		= req.app.get('driver'); 
	var file 		= req.files['file'];
	var owner_id 	= req.session.user_id;
	var target_id   = req.body.target_id;

	driver.command('attachment/create', { 
		size 		: file.size,
		name 		: file.name,
		type 		: 'image',
		ext  		: file.extension,
		path 		: file.path,
		thumb_s 	: req.body.thumbs.thumb_s,
		thumb_b 	: req.body.thumbs.thumb_b,
		owner_id 	: owner_id,
		target_id	: target_id
	})
	.then(function(data) {
		return serialize.success(data);
	})
	.fail(function(data){
		return serialize.error(data);
	})
	.done(function(result){
		res.json(result);
		next();
	})
});

router.post('/file', requireAuthentication, function (req, res, next) {
	var driver 		= req.app.get('driver'); 
	var file 		= req.files['file'];
	var owner_id 	= req.session.user_id;

	driver.command('attachment/create', {
		name 		: file.name,
		size 		: file.size,
		type 		: 'file',
		ext  		: file.extension,
		path 		: file.path,
		owner_id 	:  owner_id

	})
	.then(function(data) {
		return serialize.success(data);
	})
	.fail(function(data){
		return serialize.error(data);
	})
	.done(function(result){
		res.json(result);
		next();
	})
});

router.use(errorHandling);

module.exports = router;
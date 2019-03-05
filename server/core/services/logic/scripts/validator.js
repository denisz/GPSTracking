module.exports = {
	'/list' : {
		'last_id' : function (req) { 
			req.checkBody('last_id', 'required').notEmpty();
		},
		'limit': function(req) {
			req.checkBody('limit', 'required').isInt({min:0, max: 50});
		}
	}
};

var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Session = new Schema({
    user_id     : Schema.Types.ObjectId,
    session_id  : {type : String, index: { unique: true }},
    email 		: String,
    apn_token 	: String,
	gcm_token	: String,
    social_id	: String,		
    ip          : String,
    ua          : String, 
    created_at  : { type: Date, default: Date.now }
});

module.exports = Session;
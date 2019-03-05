var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Follower = new Schema({
	target_id 	: { type: Schema.Types.ObjectId}, 
	user_id 	: { type: Schema.Types.ObjectId},
	created_at  : { type: Date, default: Date.now},
    updated_at	: { type: Date, default: Date.now},
});

Follower.index({ target_id: -1,  user_id: -1 }, { unique: true })

module.exports = Follower;
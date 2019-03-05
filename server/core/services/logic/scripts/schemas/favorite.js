var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Favorite = new Schema({
	event_id 	: { type: Schema.Types.ObjectId},
	owner_id 	: { type: Schema.Types.ObjectId},
	mark_deleted: { type: Boolean, default: false},
	created_at  : { type: Date, default: Date.now},
	updated_at	: { type: Date, default: Date.now}
});

Favorite.index({ event_id: 1, owner_id: -1 }, { unique: true });

module.exports = Favorite;
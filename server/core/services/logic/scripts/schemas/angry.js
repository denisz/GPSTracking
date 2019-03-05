var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Angry = new Schema({
	target_id 	: { type: Schema.Types.ObjectId},
	owner_id 	: { type: Schema.Types.ObjectId},
	reason 		: { type: Number, enum: [ 0, 1, 2, 3, 4, 5, 6 ], default: 0},
	mark_deleted: { type: Boolean, default: false},
	created_at  : { type: Date, default: Date.now},
	updated_at	: { type: Date, default: Date.now}
});

Angry.index({ event_id: 1, owner_id: -1 }, { unique: true });

module.exports = Angry;
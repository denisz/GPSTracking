var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Answer = new Schema({
	object_id 	: { type: Schema.Types.ObjectId, index: { unique: true}}, 
	event_id 	: Schema.Types.ObjectId, 
	owner_id 	: { type: Schema.Types.ObjectId},
	description : { type: String},	
	status 		: { type: String, enum: [ 'accepted', 'rejected', 'dismiss' ], default: 'accepted'},
	mark_deleted: { type: Boolean, default: false},
	loc 		: { type: { type: String, required: true, enum: ['Point', 'LineString', 'Polygon'], default: 'Point'}, coordinates: [Number] },
	localized_loc : String,
	created_at  : { type: Date, default: Date.now},
    updated_at	: { type: Date, default: Date.now},
	event_context : {type: String},
	event_created_at : { type: Date, default: Date.now},
    canceled_at	: { type: Date, default: Date.now}//время ухода в архив
});

//Answer.set('autoIndex', false);
Answer.index({ event_id: 1, owner_id: -1 }, { unique: true });
Answer.index({ loc: '2dsphere' });

module.exports = Answer;
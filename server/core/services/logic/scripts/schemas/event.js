var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Event = new Schema({
	object_id 	: { type: Schema.Types.ObjectId, index: { unique: true}}, 
	description : { type: String},
	owner_id 	: { type: Schema.Types.ObjectId, index : true},
	criteria 	: {
		context 	: String,
		subtype 	: String,
		extra 		: Schema.Types.Mixed
	},
	status 		: { type: String, enum: [ 'active', 'canceled', 'banned' ], default: 'active'},
	loc 		: { type: { type: String, required: true, enum: ['Point', 'LineString', 'Polygon'], default: 'Point'}, coordinates: [Number] },
	localized_loc : String,
	meta 		: {
		comments	: Number,
		favs 		: Number
	},
	mark_deleted : {type: Boolean, default: false},
	slug      		: String,
	reason_banned 	: String,
	allow_phone 	: { type: Boolean, default: false},
	allow_email 	: { type: Boolean, default: false},
    created_at  	: { type: Date, default: Date.now},
    updated_at		: { type: Date, default: Date.now},
    visible_map_at 	: { type: Date, default: Date.now}, //время на карте
    canceled_at 	: { type: Date, default: Date.now}
  
});

//Event.set('autoIndex', false);
Event.index({ loc: '2dsphere' });

module.exports = Event;
var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Attachment = new Schema({
    owner_id 	: { type: Schema.Types.ObjectId, index: true},//userd_Id
	target_id 	: { type: Schema.Types.ObjectId, index: true},//objectID_id
	path 		: String,	
	name 		: String,
	ext 		: String,
	thumb_s		: String,
	thumb_b		: String,
	size 		: Number,
	type 		: { type: String, enum: [ 'image', 'file' ]},
	status 		: { type: String, enum: [ 'active', 'banned' ], default: 'active'},
	mark_deleted: { type: Boolean, default: false},
    created_at  : { type: Date, default: Date.now},
    updated_at  : { type: Date, default: Date.now}
});

module.exports = Attachment;
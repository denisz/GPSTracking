var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Comment = new Schema({
	owner_id 	: { type: Schema.Types.ObjectId, index: true},//userd_Id
	target_id 	: { type: Schema.Types.ObjectId, index: true},//objectid_id
	body 		: String,	
	status 		: { type: String, enum: [ 'active', 'banned'], default: 'active'},
	reason_banned: String,
	mark_deleted: { type: Boolean, default: false},
    created_at  : { type: Date, default: Date.now},
    updated_at  : { type: Date, default: Date.now}
});

//Comment.set('autoIndex', false);

module.exports = Comment;
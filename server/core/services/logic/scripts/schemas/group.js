var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var Group = new Schema({
	object_id 	: { type: Schema.Types.ObjectId, index: { unique: true}}, 
	owner_id 	: { type: Schema.Types.ObjectId},//автор группы
	mark 		: { type: String, default: "not-found"},
	title 		: { type: String},
	description : { type: String},	
	status 		: { type: String, enum: [ 'open', 'canceled', 'private' ], default: 'open'},
	mark_deleted: { type: Boolean, default: false},
	created_at  : { type: Date, default: Date.now},
    updated_at	: { type: Date, default: Date.now},
});

module.exports = Answer;
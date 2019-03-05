var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

var ObjectId = new Schema({
    type : {
    	 type: String, enum: [ 'event', 'answer' ]
    }
});

module.exports = ObjectId;
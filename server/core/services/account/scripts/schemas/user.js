var mongoose 	= require('mongoose');
var Schema 		= mongoose.Schema;

function toLower (v) {
  return v.toLowerCase();
}

var User = new Schema({
    email 		   : { type: String, set: toLower, index: { unique: true }},
    fullname 	   : String,
    passwordHash   : String,    
    social         : [
        {
            social_type : String,
            social_id   : String         
        }
    ],
    created_at 	   : { type: Date, default: Date.now},
    updated_at     : { type: Date, default: Date.now},
    status         : { type: String, enum: [ 'active', 'banned' ], default: 'active'},
    role 	       : { type: String, enum: [ 'user', 'admin', 'superuser' ], default : 'user' },
    avatar         : String,
    cover          : String,
    lang           : {type: String, default: 'ru'},
    phone 	       : String,
    settings       : {type : Schema.Types.Mixed},
    password_reset : String
});

module.exports = User;
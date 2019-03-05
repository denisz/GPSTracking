module.exports = {
	Event 	: require('./logic/scripts/event'),
	Comment : require('./logic/scripts/comment'),
	Answer  : require('./logic/scripts/answer'),
	Favorite: require('./logic/scripts/favorite'),
	Angry 	: require('./logic/scripts/angry'),
	Account : require('./account/scripts/controller'),
	Auth 	: require('./auth/scripts/controller'),
	Checkin : require('./checkin/scripts/controller'),
	Notify  : require('./notification/scripts/controller'),
	Attachment : require('./attachment/scripts/controller')
};
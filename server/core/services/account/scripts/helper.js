module.exports = {
	convertFBToUser : function (fbResult) {
		var objSocial = this.structFBSocial(fbResult);

		return {
			fullname 	: fbResult.name,
			email 		: fbResult.email,
			role 		: 'user',
			social 		: [objSocial]
		}
	},
	structFBSocial : function (fbResult) {
		var objSocial = {
			'social_type' 	: 'fb',
			'social_id' 	: fbResult.id
		};
	},

	normalizePhone: function(phone) {
		return phone.match(/\d/g).join("")
	}
}
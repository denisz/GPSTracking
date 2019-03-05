var helperLocation 	= require('./location');
var helperList 		= require('./list');
var _ = require("underscore");

module.exports = {
	//8-(960) 337-95-61 => 89603379561
	normalizePhone: function(phone) {
		if (phone) {
			return phone.match(/\d/g).join("");
			//.substring(1)
		}

		return null;
	},

	notifyAuthorRequestById: function (req, event_id, command) {
		var driver = req.app.get('driver');

		driver.command('event/get', {id: event_id})
			.then(function(data){
				var owner_id = data.event.owner_id;

				if (owner_id) {
					driver.message('notify/instance/user', {
						data 		: {
							id 		: event._id,
							context : event.criteria.context,
							subtype : event.criteria.subtype,
							owner_id: event.owner_id,
							address : event.localized_loc
						},
						user 		: owner_id,
						command 	: command
					});
				}
			})
	},

	notifyByPhone: function (req, event) {
		var driver = req.app.get('driver');

		if (event.criteria.extra && event.criteria.extra) {
			console.log(event.criteria);
			var phone = this.normalizePhone(event.criteria.extra.contacts);

			if (phone) {
				driver.command('account/phone', {phone: phone}).then(function(data) {
					console.log(data);

					if (data && data.user) {
						driver.message('notify/instance/user', {
							data 		: {
								id 		: event._id,
								context : event.criteria.context,
								subtype : event.criteria.subtype,
								owner_id: event.owner_id,
								address : event.localized_loc
							},
							user 		: data.user._id,
							command 	: 'request_wait_you'
						});
					}
				})
			}
		}
	},

	notifyAll: function (req, event) {
		var currentDevice = req.session.apn_token;
		var driver = req.app.get('driver');

		driver.command('checkin/list/near', helperLocation.parseLocationByEvent(event))
			.then(function(data) {
				driver.message('notify/instance/devices', {
					data 		: {
						id 		: event._id,
						context : event.criteria.context,
						subtype : event.criteria.subtype,
						owner_id: event.owner_id,
						address : event.localized_loc
					},
					//вот тут будут устройства
					devices 	: _.without(helperList.items(data), currentDevice),
					command 	: 'near_request_instance'
				});
			});
	},

	notify : function (req, event) {
		var context = event.criteria.context;

		if (context == "1") {
			//оповещение пользователя о новом очевидце
//			return this.notifyAuthorRequestById(req, event.id, "request_new_spectator");
			return;
		}

		if (context == "6") {
			return this.notifyByPhone(req, event);
		}

		return this.notifyAll(req, event);
	}
}
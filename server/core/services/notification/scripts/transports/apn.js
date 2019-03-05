process.env.DEBUG="apn";
var apn = require('apn');
var options = {
	"production" 	: false,
	cert 			: "support/credentials_dev/cert.pem",
	key 			: "support/credentials_dev/key.pem"
};

var apnConnection = new apn.Connection(options);
apnConnection.on("connected", function() {
	console.log("Connected");
});

apnConnection.on("transmitted", function(notification, device) {
	console.log("Notification transmitted to:" + device.token.toString("hex"));
});

apnConnection.on("transmissionError", function(errCode, notification, device) {
	console.error("Notification caused error: " + errCode + " for device ", device, notification);
	if (errCode === 8) {
		console.log("A error code of 8 indicates that the device token is invalid. This could be for a number of reasons - are you using the correct environment? i.e. Production vs. Sandbox");
	}
});

apnConnection.on("timeout", function () {
	console.log("Connection Timeout");
});

apnConnection.on("disconnected", function() {
	console.log("Disconnected from APNS");
});

apnConnection.on("socketError", console.error);

module.exports = {
	send : function (device, alert, message) {
		var myDevice 	= new apn.Device(device);
		var note 		= new apn.Notification();

		note.setExpiry(Math.floor(Date.now() / 1000) + 3600);
		note.setBadge(1);
		note.setSound("ping.aiff");
		note.setAlertText(alert);
		note.setCategory("ACTION_INTERACTIVE");
		note.payload = {'message': message};

		apnConnection.pushNotification(note, myDevice);
	}
};
var clients = {};

var getSocketByID = function (id) {
	return clients[id];
};

module.exports = {
	subscribe : function (session, socket) {
		clients[session.session_id] = socket;
	},

	unsubscribe : function (session) {
		clients[session.session_id] = null;
	},

	send : function (session, message) {
		var socket = getSocketByID(session.session_id);

		if (socket) {
			console.log("send by session_id: ", id, " message: ", message);
			socket.send(message);
			return true;
		} else {
			return false;	
		}		
	}
}
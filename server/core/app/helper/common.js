module.exports = {

	eventNotify : function (user, event) {
		var context = event.criteria.context;

		if (context == "1") {
			return false
		}

		return true;
	}
};
var _ = require("underscore");

module.exports = {
	pluck: function(list, property){
		var items = list.items;
		return _.uniq(_.pluck(items, property));
	},
	items : function (list) {
		return list.items;
	},
	count : function (list) {
		return list.items.length;
	},
	exclude: function (list, property, arrayIds) {
		list.items = _.reject(list.items, function(item){ return arrayIds.indexOf(item[property]) != -1 });
		return list
	}
}
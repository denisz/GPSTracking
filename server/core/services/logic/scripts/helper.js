var _ = require("underscore");

var secondsInMinutes 	= 60 * 1000;
var secondsInHours 		= 60 * secondsInMinutes;
var secondsInDay 		= 24 * secondsInHours;

var addHours = function (date, hours) {
	return new Date(date.getTime() + hours * secondsInHours);
};

var minusHours = function (date, hours) {
	return new Date(date.getTime() - hours * secondsInHours);
};

var addDay = function (date, days) {
	return new Date(date.getTime() + days * secondsInDay);
};

var minusDay = function (date, days) {
	return new Date(date.getTime() - days * secondsInDay);
};

var addMinute = function (date, minutes) {
	return new Date(date.getTime() + minutes * secondsInMinutes);
};

var minusMinute = function (date, minutes) {
	return new Date(date.getTime() - minutes * secondsInMinutes);
};

var eventWithSpectator = ["3", "7"];

module.exports = {

	calculateCanceledTime: function (event) {
		var context = event.criteria.context;

		if (context == "1") {
			return 	addHours(new Date(), 3)
		}

		if (context == "7") {
			return  addDay(new Date(), 1)
		}

		if (context == "4") {
			return  addDay(new Date(), 1)
		}

		return addDay(new Date(), 10); //10 суток потом уходит в архив
	},

	calculateVisibleMap: function (event) {
		return addMinute(new Date(), 100); //10 минут и уходит в ленту
	},

	fromArchive: function() {
		return minusDay(new Date(), 30);//минимальное расстояние для запроса если не задано
	},

	//время выбора очевидцев
	//возможно исправим от момента создания + день
	//для поиска детей сделать поисковое коно больше
	toSpectator : function(event) {
		var create = event.created_at;
		return addHours(new Date(create), 3);
	},

	//минус день на поиск очевидцев
	fromSpectator : function(event) {
		var create = event.created_at;
		return minusHours(new Date(create), 1);
	},

	eventWithSpectators: function (event) {
		var context = event.criteria.context;
		return eventWithSpectator.indexOf[context] != -1
	},

	//7 - угроза физического воздействия { разбой хулигантсво похищение } [13 17 18]
	//3 посягательство 	- 1 - угон [16]
	//3 посягательство 	- 2 - разбой [13, 18]
	//3 посягательство  - 4 - хулиганство - [13, 18]
	//3 посягательство  - 5 - скрылся с место ДТП - [16]
	//какие подтипы выбирать для очевидцев
	subtypeSpectator: function (event) {
		var context = event.criteria.context;
		var subtype =  event.criteria.subtype;

		if (context == "7") return  ["13", "17", "18"];
		if (context == "3") {
			if (subtype == "1")  return ["16"];
			if (subtype == "2")  return ["13", "18"];
			if (subtype == "4")  return ["13", "18"];
			if (subtype == "5")  return ["16"];
		}

		return []
	},

	dateNow: function () {
		var temp_datetime_obj = new Date();
		return new Date(temp_datetime_obj.toISOString());
	},

	toArchive: function() {
		return new Date()
	},

	parseGeoCoordinates: function (params) {
		var type = params.type;
		var coord =  params.coordinates;

		return [coord[0], coord[1]];
	},

	parseGeoDistance: function (params) {
		return params.distance || 1500;
	},

	getGeoDistanceMultiplier: function () {
		return 6378137;
	},

	getGeoMaxDistance: function (distance) {
		return distance / 6378137;
	},

	getGeoMaxDistanceFormFindSpectator: function (event) {
		//если поиск ребенка можно увеличить радиус поиска
		return 1000
	},

	convertListAggregateToQuery : function (aggregate) {
		var match = _.extend.apply(_, _.compact( _.pluck(aggregate, '$match') ) );
		var sort = _.extend.apply(_,  _.compact( _.pluck(aggregate, '$sort') ) );
		var limit = aggregate.$limit;

		return {
			limit : limit,
			sort  : sort,
			match : match
		}
	}
};
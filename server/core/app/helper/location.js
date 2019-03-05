module.exports = {
	parseLocationByEvent : function (event) {
		var loc = event.loc;
		var coord = loc.coordinates;

		return {
			coordinates : {
				lat : coord[1],
				lon : coord[0]
			},
			distance : 1500,
			type : loc.type
		}
	}

}
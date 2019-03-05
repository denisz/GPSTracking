var swig = require('swig');
swig.setDefaults({ loader: swig.loaders.fs(__dirname + '/tmpls' )});
swig.setDefaults({ cache: 'memory' });

var returnTmplPath = function (tmplNamed, language) {
	if (typeof language === "undefined") {
		language = "en";	
	}
	
	return language + '/' + tmplNamed + '.tmpl';
};

module.exports = {
	render : function (tmplNamed, lang, obj) {
		var path = returnTmplPath(tmplNamed, lang);
		return swig.renderFile( path, obj || {});
	},

	parseTmplFromCommand: function (command) {
		return command
	},

	stringify : function (obj) {
		return JSON.stringify(obj)
	}
};
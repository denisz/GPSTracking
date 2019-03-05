var Crawler = require("crawler");
var url = require('url');
var SimpleFileWriter = require('simple-file-writer');

var marks = {};

var c = new Crawler({
    maxConnections : 2,
    // This will be called for each crawled page
    callback : function (error, result, $) {
        var models = [];
        var markText =  $("h2").html();
        if (markText) {
            var mark = markText.replace(/<a href="(.*)">(.*)<\/a> &#x203A; (.*)/, "$3");
            console.log("find mark ", mark);

            $("nav.catalog-nav a").each(function(index, a){
                var model = $(a).text();
                models.push(model);
            })

            marks[mark] = models;    
        } else {
            console.log("error mark ")
        }
        
    },
    onDrain : function () {
        var writer = new SimpleFileWriter('./1.log');
        writer.write(JSON.stringify(marks));
        console.log("crawler finished");        
    }
});



// Queue a list of URLs
c.queue([
        "https://www.drive2.ru/r/ac",
        "https://www.drive2.ru/r/acura",
        "https://www.drive2.ru/r/alfaromeo",
        "https://www.drive2.ru/r/amc",
        "https://www.drive2.ru/r/aro",
        "https://www.drive2.ru/r/astonmartin",
        "https://www.drive2.ru/r/audi",
        "https://www.drive2.ru/r/autozam",
        "https://www.drive2.ru/r/bac",
        "https://www.drive2.ru/r/barkas",
        "https://www.drive2.ru/r/bentley",
        "https://www.drive2.ru/r/bmw",
        "https://www.drive2.ru/r/bogdan",
        "https://www.drive2.ru/r/brilliance",
        "https://www.drive2.ru/r/bugatti",
        "https://www.drive2.ru/r/buick",
        "https://www.drive2.ru/r/byd",
        "https://www.drive2.ru/r/cadillac",
        "https://www.drive2.ru/r/caterham",
        "https://www.drive2.ru/r/changan",
        "https://www.drive2.ru/r/chery",
        "https://www.drive2.ru/r/chevrolet",
        "https://www.drive2.ru/r/chrysler",
        "https://www.drive2.ru/r/citroen",
        "https://www.drive2.ru/r/cord",
        "https://www.drive2.ru/r/dacia",
        "https://www.drive2.ru/r/daewoo",
        "https://www.drive2.ru/r/daihatsu",
        "https://www.drive2.ru/r/datsun",
        "https://www.drive2.ru/r/detomaso",
        "https://www.drive2.ru/r/dodge",
        "https://www.drive2.ru/r/efini",
        "https://www.drive2.ru/r/eunos",
        "https://www.drive2.ru/r/faw",
        "https://www.drive2.ru/r/ferrari",
        "https://www.drive2.ru/r/fiat",
        "https://www.drive2.ru/r/ford",
        "https://www.drive2.ru/r/fso",
        "https://www.drive2.ru/r/geely",
        "https://www.drive2.ru/r/gmc",
        "https://www.drive2.ru/r/greatwall",
        "https://www.drive2.ru/r/hafei",
        "https://www.drive2.ru/r/haima",
        "https://www.drive2.ru/r/hawtai",
        "https://www.drive2.ru/r/holden",
        "https://www.drive2.ru/r/honda",
        "https://www.drive2.ru/r/hummer",
        "https://www.drive2.ru/r/hyundai",
        "https://www.drive2.ru/r/infiniti",
        "https://www.drive2.ru/r/ikco",
        "https://www.drive2.ru/r/isuzu",
        "https://www.drive2.ru/r/iveco",
        "https://www.drive2.ru/r/jac",
        "https://www.drive2.ru/r/jaguar",
        "https://www.drive2.ru/r/jeep",
        "https://www.drive2.ru/r/kia",
        "https://www.drive2.ru/r/ktm",
        "https://www.drive2.ru/r/lamborghini",
        "https://www.drive2.ru/r/lancia",
        "https://www.drive2.ru/r/landrover",
        "https://www.drive2.ru/r/ldv",
        "https://www.drive2.ru/r/lexus",
        "https://www.drive2.ru/r/lifan",
        "https://www.drive2.ru/r/lincoln",
        "https://www.drive2.ru/r/lotus",
        "https://www.drive2.ru/r/maserati",
        "https://www.drive2.ru/r/mazda",
        "https://www.drive2.ru/r/mercedes",
        "https://www.drive2.ru/r/mercury",
        "https://www.drive2.ru/r/merkur",
        "https://www.drive2.ru/r/mg",
        "https://www.drive2.ru/r/mini",
        "https://www.drive2.ru/r/mitsubishi",
        "https://www.drive2.ru/r/morgan",
        "https://www.drive2.ru/r/nissan",
        "https://www.drive2.ru/r/noble",
        "https://www.drive2.ru/r/nysa",
        "https://www.drive2.ru/r/oldsmobile",
        "https://www.drive2.ru/r/opel",
        "https://www.drive2.ru/r/peugeot",
        "https://www.drive2.ru/r/plymouth",
        "https://www.drive2.ru/r/pontiac",
        "https://www.drive2.ru/r/porsche",
        "https://www.drive2.ru/r/proton",
        "https://www.drive2.ru/r/renault",
        "https://www.drive2.ru/r/rollsroyce",
        "https://www.drive2.ru/r/rover",
        "https://www.drive2.ru/r/saab",
        "https://www.drive2.ru/r/saturn",
        "https://www.drive2.ru/r/scion",
        "https://www.drive2.ru/r/seat",
        "https://www.drive2.ru/r/simca",
        "https://www.drive2.ru/r/skoda",
        "https://www.drive2.ru/r/sma",
        "https://www.drive2.ru/r/smart",
        "https://www.drive2.ru/r/ssangyong",
        "https://www.drive2.ru/r/subaru",
        "https://www.drive2.ru/r/suzuki",
        "https://www.drive2.ru/r/talbot",
        "https://www.drive2.ru/r/tata",
        "https://www.drive2.ru/r/tatra",
        "https://www.drive2.ru/r/tesla",
        "https://www.drive2.ru/r/toyota",
        "https://www.drive2.ru/r/trabant",
        "https://www.drive2.ru/r/vauxhall",
        "https://www.drive2.ru/r/volkswagen",
        "https://www.drive2.ru/r/volvo",
        "https://www.drive2.ru/r/wartburg",
        "https://www.drive2.ru/r/wiesmann",
        "https://www.drive2.ru/r/willys",
        "https://www.drive2.ru/r/zx",
        "https://www.drive2.ru/r/avtokam",
        "https://www.drive2.ru/r/vis",
        "https://www.drive2.ru/r/gaz",
        "https://www.drive2.ru/r/eraz",
        "https://www.drive2.ru/r/zaz",
        "https://www.drive2.ru/r/zil",
        "https://www.drive2.ru/r/izh",
        "https://www.drive2.ru/r/kamaz",
        "https://www.drive2.ru/r/lada",
        "https://www.drive2.ru/r/luaz",
        "https://www.drive2.ru/r/moskvich",
        "https://www.drive2.ru/r/raf",
        "https://www.drive2.ru/r/seaz",
        "https://www.drive2.ru/r/tagaz",
        "https://www.drive2.ru/r/uaz"
        ]);

// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


Parse.Cloud.define("fetchQuestions", function(request, response) {
  var latitude = request.params.latitude;
  var longitude = request.params.longitude;
  var geoPointLoc = new Parse.GeoPoint(latitude,longitude);
  var questionArray = [];

  //creating query 
  var Hotspot = Parse.Object.extend("Hotspot");
  var questionQuery = new Parse.Query(Hotspot);
  
  //constraining query : created less than an hour ago + within 100 meters of user.
  questionQuery.withinKilometers("location", geoPointLoc, 0.1);
  questionQuery.limit(3);
  var oneHourAgo = new Date();
  oneHourAgo.setHours(oneHourAgo.getHours() - 1);
  questionQuery.greaterThanOrEqualTo("createdAt", oneHourAgo);

  //iterating through returned objects
  questionQuery.find({
	  success: function(hotspotEntries) {
	  	for(var i = 0; i < hotspotEntries.length; i++){
	  		var questionDict = {}
	  		var entry = hotspotEntries[i];
	  		var tag = entry.get("tag");
	  		var infoDict = entry.get("info");
	  		var location = entry.get("location");
	  		var latitude = location.latitude;
	  		var longitude = location.longitude;
	  		questionDict["id"]=entry.id;
	  		questionDict["latitude"] = latitude;
	  		questionDict["longitude"] = longitude;
	  		questionDict["date"] = entry.get("createdAt");
 	  		if (tag == ""){
 	  			questionDict["tag"] = "What's here?";
	  		}else if (tag == "food"){
	  			if (infoDict !== undefined){
	  				for (var infotype in infoDict) {
					    if (infoDict.hasOwnProperty(infotype)) {
					    	if (infoDict[infotype] == ""){
					    		questionDict[infotype] = infotype + "?";  		
					    	}else{
					    		questionDict[infotype] = infoDict[infotype];
					    	}
					    }
					}
	  			}
	  		}
	  		questionArray.push(questionDict);
	  	}
	  	response.success(questionArray);
	  }
	});



  //var dict = {"coordinates":[latitude,longitude]}; //use dict.coordinates[0] to get latitude
  //response.success(dict);
});

Parse.Cloud.afterSave('Hotspot', function(request, response) {
	var savedObject = request.object;
	var tag = savedObject.get("tag");
	var infoDict = savedObject.get("info");
	var dict = {};
	if (tag == "food" && ( (infoDict == undefined) || (Object.keys(infoDict) == 0) )) {
		dict["type"] = "";
		dict["duration"] = "";
		savedObject.set("info", dict);
		savedObject.save(null, {
		  success: function(savedObject) {
		  },
		  error: function(savedObject, error) {
		  }
		});
	} else if ((infoDict == undefined) || (Object.keys(infoDict) == 0)){
		savedObject.set("info", dict);
		savedObject.save(null, {
		  success: function(savedObject) {
		  },
		  error: function(savedObject, error) {
		  }
		});
	}
    // code here
})


var vid = document.getElementById("audio");
var gunshot = new sound("audio/gunshot.mp3")

function sound(src) {
	this.sound = document.createElement("audio");
	this.sound.src = src;
	this.sound.setAttribute("preload", "auto");
	this.sound.setAttribute("controls", "none");
	this.sound.style.display = "none";
	document.body.appendChild(this.sound);
	this.play = function(){
			this.sound.play();
	}
	this.stop = function(){
			this.sound.pause();
	}
}

function enableAutoplay() { 
	vid.autoplay = true;
	vid.loop = true;
	vid.load();
}
imgtype = 0;

function animatedown(image){
	height = "+=" + $(document).height();

	$(image).animate({
		left: height
	}, 10000, function() {
		// Animation complete.
	});
}

function createsoldier(){
	var x = document.createElement("IMG");
	if (imgtype == 0) {
		x.setAttribute("src", "images/runsoldier1.png");
		imgtype = 1;
	} else if (imgtype == 1){
		x.setAttribute("src", "images/runsoldier2.png");
		imgtype = 2;
	} else if (imgtype == 2){
		x.setAttribute("src", "images/runsoldier3.png");
		imgtype = 0;
	}
	x.setAttribute("width", "200");
	x.setAttribute("height", "200");
	document.getElementById("soldiers").appendChild(x);
}

function iterateRecords(resources) {
	console.log(resources);
	solution = resources[Math.floor(Math.random() * resources.length)];
	for (i = 0; i < 8; i++) { 
		$('#teamlist').append(
			$('<img>').attr('src', solution['High resolution image'])
		);
		solution = resources[Math.floor(Math.random() * resources.length)];
	}
}

function retrieveResources(amount) {
	var reqParam;
	reqParam = {
	  resource_id: 'cf6e12d8-bd8d-4232-9843-7fa3195cee1c',
	  limit: amount
	};
	return $.ajax({
	  url: 'https://data.gov.au/api/action/datastore_search',
	  data: reqParam,
	  dataType: 'jsonp',
	  cache: true
	});
};
function processData(data) {
	var item, j, len, processedData, ref;
	processedData = [];
	ref = data.result.records;
	for (j = 0, len = ref.length; j < len; j++) {
	  item = ref[j];
	  if (item['High resolution image']) {
		processedData.push(item);
	  }
	}
	return processedData;
};


$(document).ready(function(){
	enableAutoplay();
	retrieveResources(50).then(function(res) {
        iterateRecords(processData(res));
      });

	$(document).mousemove(function(e){
		$('.scope').css('left',e.pageX+"px");
		$('.scope').css('top',e.pageY+"px");
	});



	for (i = 0; i < 6; i++) { 
		var randx = Math.floor((Math.random() * 200));
		var randy = Math.floor((Math.random() * 200) + 400);
		createsoldier();
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("position", "absolute");
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("left", randx);
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("float", "left");
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("top", randy);
	}
	
	setTimeout(function(){animatedown("#soldiers img")},20000);

	$("body").click(function(){
		gunshot.play();
		$('.scope').css("pointer-events", "auto");
		setTimeout(function(){$('.scope').css("pointer-events", "none");},3000);
	});
	$("#soldiers img").click(function(){
		$(this).attr('src', 'images/deadsoldier.png');
		$(this).attr("height", "auto");
		$(this).attr("width", "300px");
		console.log("friendlyshot");
		$('.scope').css("pointer-events", "auto");
		setTimeout(function(){$('.scope').css("pointer-events", "none");},3000);
	});
});




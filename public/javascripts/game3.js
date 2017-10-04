var vid = document.getElementById("audio");
var gunshot = new sound("audio/gunshot.mp3")
var machinegunsound = new sound("audio/machinegun.mp3")

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

function animateright(image){
	right = "+=" + $(document).height();

	$(image).animate({
		left: right
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
	x.setAttribute("class", "allysoldier");
	document.getElementById("soldiers").appendChild(x);
}

function createmachinegun(){
	var x = document.createElement("IMG");
	x.setAttribute("src", "images/machineguncrew.png");
	x.setAttribute("class", "machinegun");
	document.getElementById("enemy").appendChild(x);
}

function iterateRecords(resources, lives) {
	console.log(resources);
	solution = resources[Math.floor(Math.random() * resources.length)];
	for (i = 0; i < lives; i++) { 
		$('#teamlist').append(
			$('<img>').attr('src', solution['High resolution image']),
			$('<div>').attr('class', 'middle')
		);
		$('.middle').html("<p>KIA<p>");
		solution = resources[Math.floor(Math.random() * resources.length)];
	}
}

function soldierdeath(j){
	$("teamlist img:nth-of-type(" + j + ")").css("opacity", 0.3);
	$(".middle:nth-of-type(" + j + ")").css("opacity", 1);
	j = j + 1;
	console.log("deadsoldier")
}

function losegame(){
	$('#teamlist').css("pointer-events", "auto");
	$('#teamlist h1').html("Your battalion was wiped out");
	$('#teamlist').append("<input type='button' value='Restart' onClick='window.location.reload()'>");
}

function wingame(score){
	$('#teamlist').css("pointer-events", "auto");
	$('#teamlist h1').html("Your battalion has made it to the enemy. " +score+ " of your battalion survived.");
	$('#teamlist').append("<input type='button' value='Next Level' onClick='level2()'>");
}

function level2(){
	$('#level1').hide();
	$("body").css("background-image",'url("../views/images/town.jpg")');
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
	$("#level2").hide()
	battalionnum = 10
	enableAutoplay();
	retrieveResources(100).then(function(res) {
        iterateRecords(processData(res), battalionnum);
      });

	$(document).mousemove(function(e){
		$('.scope').css('left',e.pageX+"px");
		$('.scope').css('top',e.pageY+"px");
	});


	for (i = 0; i < battalionnum; i++) { 
		var randx = Math.floor((Math.random() * 200));
		var randy = Math.floor((Math.random() * 200) + 400);
		createsoldier();
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("position", "absolute");
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("left", randx);
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("float", "left");
		$("#soldiers img:nth-of-type(" + (i+1) + ")").css("top", randy);
	}

	for (i = 0; i < 3; i++) { 
		var randx = Math.floor((Math.random() * 100) - 100);
		var randy = Math.floor((Math.random() * 200) + 400);
		createmachinegun();
		$("#enemy img:nth-of-type(" + (i+1) + ")").css("position", "absolute");
		$("#enemy img:nth-of-type(" + (i+1) + ")").css("right", randx);
		$("#enemy img:nth-of-type(" + (i+1) + ")").css("float", "left");
		$("#enemy img:nth-of-type(" + (i+1) + ")").css("top", randy);
	}


	setTimeout(function(){animateright("#soldiers .allysoldier")},20000);

	var deadsoldiers = 1;
	setTimeout(function(){
		var machinegunExists = document.getElementsByClassName("machinegun");
		console.log(machinegunExists.length);
		if (machinegunExists.length != 0){
			machinegunsound.play();
			var bulletstorm = setInterval(function(){
				$("#soldiers .allysoldier:nth-of-type(" + deadsoldiers + ")").attr("height", "auto");
				$("#soldiers .allysoldier:nth-of-type(" + deadsoldiers + ")").stop();
				$("#soldiers .allysoldier:nth-of-type(" + deadsoldiers + ")").attr("width", "300px");
				$("#soldiers .allysoldier:nth-of-type(" + deadsoldiers + ")").attr('src', 'images/deadsoldier.png');
				$("#soldiers .allysoldier:nth-of-type(" + deadsoldiers + ")").attr('class', 'corpse');
				soldierdeath(deadsoldiers);
				deadsoldiers += 1;
				if (deadsoldiers > 10) {
					losegame();
					clearInterval(bulletstorm);
				}
			}, 500)
		} else {
			setTimeout(function(){
				wingame(battalionnum - deadsoldiers + 1);
			}, 10000)
		}
	},20000);



	var shoot = 0
	$("*").click(function(){
		if (shoot == 0){
			gunshot.play();
			console.log("shot");
		} else {
			console.log("reloading")
		}
	});
	
	$("#soldiers .allysoldier").click(function(){
		if (shoot == 0){
			console.log("shot");
			$(this).attr('src', 'images/deadsoldier2.png');
			$(this).attr('class', 'corpse');
			$(this).attr("height", "auto");
			$(this).attr("width", "300px");
			$(this).stop();
			shoot = 1;
			setTimeout(function(){shoot = 0;},3000);
			soldierdeath(11 - battalionnum);
			battalionnum -= 1;
			if (0 > battalionnum) {
				losegame();
			}
		} else {
			console.log("shreloading")
		}
	});
	$(".machinegun").click(function(){
		if (shoot == 0){
			console.log("shot");
			$(this).attr('src', 'images/deadsoldier.png');
			$(this).attr('class', 'corpse');
			$(this).attr("height", "auto");
			$(this).attr("width", "300px");
			shoot = 1;
			setTimeout(function(){shoot = 0;},3000);
		} else {
			console.log("shreloading")
		}
	});
});




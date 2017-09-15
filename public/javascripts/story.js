var step = 0;

$(document).ready(function(){
  $(".loaderContent h1").css("font-weight", "900");

  $("#story").css("background-color", "#101010");

  $("#back").hide();
  $("#story img").hide();
  $("#subspace p").hide();
  /*$("#chap1sub p").hide();
  $("#house").hide();
  $("#room").hide();
  $("#mother").hide();
  $("#son").hide();
  $("#eye").hide();
  $("#ripping").hide();
  $("#letter").hide();
  $("#desk").hide();
  $("#scraps").hide();
  $("#hand").hide();
  */

  //$("#chap2sub1 p").hide();
  //$("#recruitOffice").hide();
  //$("#newsOffice").hide();
  //$("#mattBack").hide();

  $("#chapTitle").click(function(){
    $("#chapTitle").delay(500).fadeOut(1500,"linear");
    $("#house").delay(2000).fadeIn(2000,"linear");
    $("#recruitOffice").delay(2000).fadeIn(2000,"linear");
  });

  $("#house").click(function(){
    $("#chap1img").fadeIn();
    $("#house").fadeOut(1000,"linear");
    $("#room").delay(1000).fadeIn(1500,"linear");
    $("#mother").delay(1500).fadeIn(1000,"linear");
  });

  $("#chap1img img").click(function(){
    step = step + 1;
    if(step == 1){
      $("#son").fadeIn(500,"linear");
      $("#chap1sub p:nth-of-type("+ 1 +")").delay(500).fadeIn(1000,"linear");
    }else if(step == 2){
      $("#chap1sub p:nth-of-type("+ 1 +")").fadeOut(500,"linear");
      $("#chap1sub p:nth-of-type("+ 2 +")").delay(1500).fadeIn(1000,"linear");
      $("#eye").delay(1000).fadeIn(1000,"linear");
      $("#room, #mother, #son").delay(2000).fadeOut(100);
    }else if(step == 3){
      $("#chap1sub p:nth-of-type("+ 2 +")").fadeOut(1000,"linear");
      $("#eye").fadeOut(1000,"linear");
      $("#ripping").delay(500).fadeIn(1000,"linear");
      $("#chap1sub p:nth-of-type("+ 3 +")").delay(1000).fadeIn(1000,"linear")
    }else if(step > 3 && step < 5){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#chap1sub p:nth-of-type("+ step +")").delay(500).fadeIn(1000,"linear")
      console.log(step);
    }else if(step == 5){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#ripping").fadeOut(1000,"linear");
      $("#letter").delay(1000).fadeIn(1500,"linear");
      $("#chap1sub p:nth-of-type("+ step +")").delay(1500).fadeIn(1000,"linear")
    }else if(step == 6){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#chap1sub p:nth-of-type("+ step +")").delay(1000).fadeIn(1000,"linear");
      $("#letter").fadeOut(1000,"linear");
      $("#desk").delay(1500).fadeIn(2000,"linear");
      $("#scraps").delay(1500).fadeIn(2000,"linear");
    }else if(step == 7){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#chap1sub p:nth-of-type("+ step +")").delay(500).fadeIn(1000,"linear");
      $("#hand").fadeIn({queue: false, duration: 2500});
      $("#hand").animate({top: "45%"}, 3000);
    }else if(step == 8){
      $("#back").fadeIn(500,"linear");
    }
  });

  $("#recruitOffice").click(function(){
    if(step < 4){
      $("#chap2sub1 p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#chap2sub1 p:nth-of-type("+ step +")").delay(500).fadeIn(1000,"linear");
    }else if(step == 4){
      $("#chap2sub1 p:nth-of-type("+ step +")").fadeOut(500,"linear");
      $("#recruitOffice").fadeOut(1000,"linear");
      $("#newsOffice").delay(1000).fadeIn(1500,"linear");
      $("#mattBack").delay(1500).fadeIn(1000,"linear");
      step = 0;
    }
  });

  $("#chap2img").click(function(){
    step = step + 1;
    if(step == 1){
      $("#chap2sub2 p:nth-of-type("+ 1 +")").fadeIn(1000,"linear");
    }else if(step == 2){
      $("#mattBack").fadeOut(1000,"linear");
      $("#newsOffice").delay(500).fadeOut(1000,"linear");
      $("#chap2sub2 p:nth-of-type("+ 1 +")").fadeOut(500,"linear");
      $("#insideOffice").delay(500).fadeIn(1000,"linear");
    }else if(step < 6){
      step = step - 2;
      $("#chap2sub2 p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#chap2sub2 p:nth-of-type("+ step +")").delay(500).fadeIn(1000,"linear");
      step = step + 1;
    }else if(step = 6){
      $("#chap2sub2 p:nth-of-type("+ 4 +")").fadeOut(500,"linear");
      $("#mattPh").delay(500).fadeIn(1000,"linear");
    }
  });

  $("#mattPh").click(function(){
    $("#back").fadeIn(500,"linear");
  });
});

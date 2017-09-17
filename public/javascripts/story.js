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
    $("#watchtowerOut").delay(2000).fadeIn(2000,"linear");
    $("#warEnds").delay(2000).fadeIn(2000,"linear");
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

  $("#watchtowerOut").click(function(){
    $("#watchtowerOut").fadeOut(1000,"linear");
    $("#watchtowerIn").delay(1000).fadeIn(1000,"linear");
    $("#dadPhoto").delay(1500).fadeIn(1000,"linear");
    $("#mattSniper").delay(1500).fadeIn(1000,"linear");
  });

  $("#chap3img").click(function(){
    step = step + 1;
    if(step == 1){
      $("#chap3sub p:nth-of-type("+ 1 +")").fadeIn(1000,"linear");
    }else if(step == 2){
      $("#chap3sub p:nth-of-type("+ 1 +")").fadeOut(500,"linear");
      $("#chap3sub p:nth-of-type("+ 2 +")").delay(500).fadeIn(1000,"linear");
    }else if(step == 3){
      $("#chap3sub p:nth-of-type("+ 2 +")").fadeOut(500,"linear");
      $("#watchtowerIn").delay(500).fadeOut(1000,"linear");
      $("#dadPhoto").fadeOut(1000,"linear");
      $("#mattSniper").fadeOut(1000,"linear");
      $("#mattAiming").delay(1500).fadeIn(1000,"linear");
      $("#chap3sub p:nth-of-type("+ 3 +")").delay(1500).fadeIn(1000,"linear");
    }else if(step == 4){
      $("#back").fadeIn(500,"linear");
    }
  });

  $("#warEnds").click(function(){
    $("#warEnds").fadeOut(1000,"linear");
    $("#mattHome").delay(1500).fadeIn(1000,"linear");
    $("#chap4sub1 p:nth-of-type("+ 1 +")").delay(1500).fadeIn(1000,"linear");
  });

  $("#chap4img1").click(function(){
    step = step + 1;
    if(step == 1){
      $("#chap4sub1 p:nth-of-type("+ 1 +")").fadeOut(500,"linear");
      $("#mattHome").fadeOut(1000,"linear");
      $("#pourMilk").delay(1000).fadeIn(1000,"linear");
      $("#chap4sub1 p:nth-of-type("+ 2 +")").delay(1000).fadeIn(1000,"linear");
    }else if(step == 2){
      $("#chap4sub1 p:nth-of-type("+ 2 +")").fadeOut(500,"linear");
      $("#pourMilk").delay(1000).fadeOut(100,"linear");
      $("#flashBackBlur").delay(500).fadeIn(100,"linear");
      $("#flashBack").delay(600).fadeIn(300,"linear");
    }else if(step == 3){
      $("#flashBack").fadeOut(300,"linear");
      $("#flashBackBlur").delay(100).fadeOut(1000,"linear");
      $("#dropMilk1").delay(1100).fadeIn(1000,"linear");
      $("#dropMilk2").delay(2100).fadeIn(1000,"linear");
    }else if(step == 4){
      $("#dropMilk1").fadeOut(0);
      $("#dropMilk2").fadeOut(1000,"linear");
      $("#roomBlur").delay(1000).fadeIn(1000,"linear");
      $("#mattDrink").delay(1000).fadeIn(1000,"linear");
      $("#chap4sub1 p:nth-of-type("+ 3 +")").delay(1000).fadeIn(1000,"linear")
    }else if(step == 5){
      $("#roomBlur").fadeOut(1500,"linear");
      $("#mattDrink").fadeOut(1500,"linear");
      $("#chap4sub1 p:nth-of-type("+ 3 +")").fadeOut(1000,"linear");
      $("#office").delay(1500).fadeIn(1000,"linear");
      $("#mattSuit").delay(1500).fadeIn(1000,"linear");
      $("#boss").delay(1500).fadeIn(1000,"linear");
      step = 0
    }
  });

  $("#chap4img2").click(function(){
    if(step < 4){
      $("#chap4sub2 p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#chap4sub2 p:nth-of-type("+ step +")").delay(500).fadeIn(1000,"linear");
    }else if(step == 4){
      $("#chap4sub2 p:nth-of-type("+ step +")").fadeOut(500,"linear");
      step = step + 1;
      $("#office").fadeOut(1000,"linear");
      $("#boss").fadeOut(500,"linear");
      $("#mattSuit").fadeOut(500,"linear");
      $("#mattHand").delay(1000).fadeIn(1500,"linear");
      $("#chap4sub2 p:nth-of-type("+ step +")").delay(1500).fadeIn(1000,"linear");
    }else if (step == 5){
      $("#back").fadeIn(500,"linear");
    }
  });
});

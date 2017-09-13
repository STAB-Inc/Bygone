var step = 0;

$(document).ready(function(){
  $(".open").click(function(){
    $("#navTab").animate({right: 0});
    $(".open").text(">");
  });

  /*$("#navTab").mouseenter(function(){
    $("#navTab").animate({right: 0});
  });*/

  $("#navTab").mouseleave(function(){
    $("#navTab").animate({right: "-510px"});
    $(".open").text("<");
  });

  $("#chap1sub p").hide();
  $("#chap1img p").hide();
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

  $("#house").delay(500).fadeIn(2000,"linear");
  $("#house").click(function(){
    $("#chap1img").fadeIn();
    $("#house").fadeOut(1000,"linear");
    $("#room").delay(1000).fadeIn(1500,"linear");
    $("#mother").delay(1500).fadeIn(1000,"linear");
  });

  $("#chap1img").click(function(){
    step = step + 1;
    if(step == 1){
      $("#son").fadeIn(500,"linear");
      $("#chap1sub p:nth-of-type("+ 1 +")").delay(500).fadeIn(1000,"linear");
    }else if(step == 2){
      $("#chap1sub p:nth-of-type("+ 1 +")").fadeOut(1000,"linear");
      $("#chap1sub p:nth-of-type("+ 2 +")").delay(2000).fadeIn(1000,"linear");
      $("#eye").delay(1500).fadeIn(1000,"linear");
      $("#room, #mother, #son").delay(2500).fadeOut(100);
    }else if(step == 3){
      $("#chap1sub p:nth-of-type("+ 2 +")").fadeOut(1500,"linear");
      $("#eye").fadeOut(1500,"linear");
      $("#ripping").delay(1000).fadeIn(1000,"linear");
      $("#chap1sub p:nth-of-type("+ 3 +")").delay(1500).fadeIn(1000,"linear")
    }else if(step > 3 && step < 5){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(1000,"linear");
      step = step + 1;
      $("#chap1sub p:nth-of-type("+ step +")").delay(1500).fadeIn(1500,"linear")
      console.log(step);
    }else if(step == 5){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(1500,"linear");
      step = step + 1;
      $("#ripping").fadeOut(1500,"linear");
      $("#letter").delay(1500).fadeIn(2000,"linear");
      $("#chap1sub p:nth-of-type("+ step +")").delay(2000).fadeIn(1000,"linear")
    }else if(step == 6){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(1500,"linear");
      step = step + 1;
      $("#chap1sub p:nth-of-type("+ step +")").delay(2000).fadeIn(1000,"linear");
      $("#letter").fadeOut(1500,"linear");
      $("#desk").delay(1500).fadeIn(2000,"linear");
      $("#scraps").delay(1500).fadeIn(2000,"linear");
    }else if(step == 7){
      step = step - 1;
      $("#chap1sub p:nth-of-type("+ step +")").fadeOut(1000,"linear");
      step = step + 1;
      $("#chap1sub p:nth-of-type("+ step +")").delay(1000).fadeIn(1000,"linear");
      $("#hand").fadeIn({queue: false, duration: 2500});
      $("#hand").animate({top: "45%"}, 3000);
    }

  });
});

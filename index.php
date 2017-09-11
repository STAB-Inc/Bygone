<?php include "views/layout"; ?>

  <div id="loader">
    <div class="loaderContent">
      <h1>BYGONE</h1>
      <div class="spinnerContainer">
        <div class="spinner"></div>
        <div class="spinner2"></div>
        <div class="spinner3"></div>
      </div>
      <div class="loaderBar">
      </div>
    </div>
  </div>
  <body id="index">
    <img src="Bygone.Resources/index.jpg" />
    <main>
      <div class="container-fluid">
        <div class="row header">
          <h1>BYGONE</h1>
          <h3>A Soldier's Tale</h3>
        </div>
        <div class="row">
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
        </div>
        <div class="row buttons">
          <div class="row">
            <div class="col-lg-7">
              <a href="">
                <div class="buttonContainer">
                  <h3><b>PLAY</b></h3>
                </div>
              </a>
            </div>
            <div class="col-lg-offset-1 col-lg-4">
              <a href="">
                <div class="buttonContainer">
                  <h3>HIGH SCORES</h3>
                </div>
              </a>
            </div>
          </div>
          <div class="row">
            <div class="col-lg-7">
              <a href="">
                <div class="buttonContainer">
                  <h3><b>FREE MODE</b></h3>
                </div>
              </a>
            </div>
            <div class="col-lg-offset-1 col-lg-4">
              <a href="">
                <div class="buttonContainer">
                  <h3>ABOUT</h3>
                </div>
              </a>
            </div>
          </div>
        </div>
      </div>      
    </main>
    <section id="campaign">
      <img src="Bygone.Resources/campaign.jpg" />
      <div class="container-fluid">
        <div class="row">
          <a href="">
            <div class="col-lg-3 col-md-6 chapter ch1">
              <div class="stateContainer">
              </div>
              <div class="textContainer">
                <h3>CHAPTER 1</h3>
                <p>Story section – Matt sees his mother ripping up a picture of the father after she hears the news of his death. Matt, who has never seen his father, since he left before he was born for the war picks up the ripped picture and tries to put the pieces back together – transfer to game.</p>
              </div>
              <div class="unlockContainer">
                <p>Unlocks Chapter 2</p>
                <p>Unlocks Puzzle Game</p>
              </div>
            </div>
          </a>
          <a href="">
            <div class="col-lg-3 col-md-6 chapter ch2">
              <div class="stateContainer">
                <i class="ion-locked"></i>
              </div>
              <div class="textContainer">
                <h3>CHAPTER 2</h3>
                <p>2nd section – Matt, 17 works as a photographer just as the war erupts. He is sad as he is not yet old enough to join the war and wants to go to war like his father did. We see his life in an office, being frantically told about where he must go for his next job – transfer to game.</p>
              </div>
              <div class="unlockContainer">
                <p>Unlocks Chapter 3</p>
                <p>Unlocks Photography Game</p>
              </div>
            </div>
          </a>
          <a href="">
            <div class="col-lg-3 col-md-6 chapter ch3">
              <div class="stateContainer">
                <i class="ion-locked"></i>
              </div>
              <div class="textContainer">
                <h3>CHAPTER 3</h3>
                <p>3rd section – We see Matt at Gallipoli, in the war as a sniper. We see a photograph of his dad next to him as he is in a watchtower. He says something as we see him targeting someone before he shoots – transfer to game. Game ends with a mortar blast near him .</p>
              </div>
              <div class="unlockContainer">
                <p>Unlocks Chapter 4</p>
                <p>Unlocks Shooting Game</p>
              </div>
            </div>
          </a>
          <a href="">
            <div class="col-lg-3 col-md-6 chapter ch4">
              <div class="stateContainer">
                <i class="ion-locked"></i>
              </div>
              <div class="textContainer">
                <h3>CHAPTER 4</h3>
                <p>4th section – back at home after the war he is still trying to be a photographer. Owner is very angry as business is bad due to war etc. we see him struggle to do simple tasks because of shaky hands and shell shock. He gets a job again – transfer to game.</p>
              </div>
              <div class="unlockContainer">
                <p>Unlocks Free Mode Plus</p>
                <p>Unlocks Photography Mode Plus</p>
              </div>
            </div>  
          </a>
        </div>
      </div>
    </section>
    <section id="freeMode">

    </section>
  </body>
  <script src="bower_components/jquery/dist/jquery.min.js"></script>
  <script src="bower_components/imagesloaded/imagesloaded.pkgd.min.js"></script>
  <script src="public/javascripts/main_script.js"></script>
</html>
###
@file
Handles the functionality of the photography game.
###

jQuery(document).ready ->

  class event

    ###
      Constructs the event object.
      @constructor
      @param {string} title
        Title of the event.
      @param {string} time
        The game time of when the event occurred.
      @param {string} content
        The description of the event.
      @param {boolean} special
        Whether if the event is a special event.
      @param {boolean} warn
        Whether if the event is a warning.
    ###

    constructor: (@title, @time, @content, @special=false, @warn=false) ->

  class randomEvent extends event
    constructor: (@title, @time, @content, @special=false, @popup=false, @chance, @effects) ->
      super(@title, @time, @content, @special, @warn)

  class gamePhoto

    ###
      Constructs the game photo object.
      @constructor
      @param {integer} value
        The value of the photo.
      @param {boolean} washed
        Whether if the photo has been washed
      @param {string} img
        The image associated with the photo.
      @param {string} title
        The title of the photo.
      @param {integer} quailty
        The quailty of the photo.
    ###

    constructor: (@value, @washed, @img, @title, @quailty) ->

  ###
    Global variables and constants.
  ###

  locations = []
  validData = []
  gameGlobal = {
    init: {
      isStory: false
      isPlus: false
      stats: {
        CAB: 1000, 
        workingCapital: 0
        assets: 0, 
        liabilities: 600
      }
    },
    trackers: {
      monthPassed: 0
      photosSold: 0
      moneyEarned: 0
    },
    turnConsts: {
      interest: 1.5
      pictureWashingTime: 14
      stdLiabilities: 600
      alert: false
      randomEvents: [
        new randomEvent('Machine Gun Fire!', 
        'currentTime', 'You wake up in a cold sweat. The sound of a german machine gun barks out from the window. How coud this be? Germans in Australia? You grab your rifle from under your pillow and rush to the window. You ready your rifle and aim, looking for the enemy. BANG! BANG! BARK! YAP! You look at the neighbours small terrier. Barking...', 
        false, true, 100, effects = {insanity: 20}),
        new randomEvent('German Bombs!', 
        'currentTime', 'A loud explosion shakes the ground and you see a building crumble into dust in the distance. Sirens. We have been attacked! You rush to see the chaos, pushing the bystanders aside. They are not running, strangely calm. Do they not recognize death when the see it? Then you see it. A construction crew. Dynamite.', 
        false, true, 10, effects = {insanity: 30}),
        new randomEvent('Air raid!', 
        'currentTime', 'The sound of engines fills the air. The twins propellers of a German byplane. You look up to the sky, a small dot. It may be far now, but the machine guns will be upon us soon. Cover. Need to get safe. You yell to the people around you. GET INSIDE! GET INSIDE NOW! They look at you confused. They dont understand. You look up again. A toy. You look to your side, a car.', 
        false, true, 14, effects = {insanity: 20}),
        new randomEvent('Landmines!', 
        'currentTime', 'You scan the ground carefully as you walk along the beaten dirt path. A habit you learned after one of your squadmate had his legs blown off by a German M24 mine. You stop. Under a pile of leaves you spot it. The glimmer of metal. Shrapnel to viciously tear you apart. You are no sapper but this could kill someone. You throw a rock a it. The empty can of beans rolls away.', 
        false, true, 20, effects = {insanity: 10}),
        new randomEvent('Dazed', 
        'currentTime', 'You aim the camera at the young couple who had asked you for a picture. Slowly. 3. 2. 1. Click. FLASH. You open your eyes. The fields. The soldiers are readying for a charge. OVER THE TOP. You shake yourself awake. The couple is looking at you worryingly. How long was I out?', 
        false, true, 10, effects = {insanity: 5}),
        new randomEvent('The enemy charges!', 
        'currentTime', 'You are pacing along the street. Footsteps... You turn round and see a man running after you. Yelling. Immediately you run at him. Disarm and subdue you think. Disarm. You tackle him to the ground. He falls with a thud. Subdue. You raise your fist. As you prepare to bring it down on your assailant. Its your wallet. "Please stop! You dropped your wallet! Take it!', 
        false, true, 10, effects = {insanity: 20})
      ]
    }
  }

  ###
    Submits session data to the server. 
    @param {object} data 
      the data to be submitted.

    @return 
      AJAX deferred promise.
  ###

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data
  
  ###
    Display the response status to the DOM
    @param {DOMElement} target
      The DOM element to display the response to.

    @param {object} res
      The response to display.
  ###

  showResStatus = (target, res) ->
    if res.status == 'success'
      $(target).css 'color', ''
      $(target).text res.message
    else
      $(target).css 'color', 'red'
      $(target).text res.message

  ###
    Saves the current user score.
  ###

  saveScore = ->
    submitUserData({
      method: 'saveScore'
      gameId: '2'
      value: @score
    }).then (res) ->
      showResStatus '#gameEnd .status', JSON.parse res

  ###
    Saves the a item to the user's collection.
  ###

  saveItem = (img, des) ->
    submitUserData({
      method: 'saveItem'
      image: img
      description: des
    }).then (res) ->
      showResStatus '#savePicOverlay .status', JSON.parse res

  ###
    Gets the value of the paramater in the query string of a GET request.
    @param {string} name 
      the key of the corrosponding value to retrieve.

    @return 
      The sorted array.
  ###

  getParam = (name) ->
    results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href)
    return results[1] || 0

  ###
    Retrieves the GET paramater from the query string. Sets up the interface and game constants accordingly.
  ###

  try
    storyMode = getParam('story') == 'true'
    plusMode = getParam('plus') == 'true'
    if storyMode
      gameGlobal.init.isStory = true
      $('.tutorial .init').text 'Welcome to the photography game. As Mark, you must do your job for at least 6 month. Do not let your Working Capital drop below -$2000.'
      $('#playAgain').text 'Continue'
      $('#playAgain').parent().attr 'href', 'chapter3.html'
      $('.skip').show()
      $('.save').hide()
      $('#playAgain').addClass('continue')
    if getParam('diff') == 'extended'
      gameGlobal.init.stats = {
        CAB: 2500, 
        workingCapital: 0, 
        assets: 0, 
        liabilities: 1000
      }
    if plusMode
      gameGlobal.init.isPlus = true

  ###
    Skips the game when in story mode. Completes the chapter for the user.
  ###

  $('.skip, .continue').click (e) ->
    $('.continueScreen').show()
    $('#selectionArea, #gameArea').hide()
    submitUserData({
      method: 'chapterComplete'
      chapterId: '2'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        return 0

  ###
    Retrieves resources from the dataset.
    @param {integer} amount
      The amount of resources to retrieve.

    @return
      AJAX deferred promise.
  ###

  retrieveResources = (amount) ->
    reqParam = {
      resource_id: '9913b881-d76d-43f5-acd6-3541a130853d',
      limit: amount
    }
    $.ajax {
      url: 'https://data.gov.au/api/action/datastore_search',
      data: reqParam,
      dataType: 'jsonp',
      cache: true
    }

  ###
    Converts degrees to radians.
    @param {float} deg
      The degree to convert to radians.

    @return
      The corrosponding radian value of the input.
  ###

  deg2rad = (deg) ->
    return deg * (Math.PI/180)

  ###
    Calculates the distance travelled from two lat, lng coordinates.
    @param {object} from
      The initial lat, lng coordinates.
    @param {object} to
      The final lat, lng coordinates.
    @return
      The distance between the two points in km.
  ###

  distanceTravelled = (from, to) ->
    lat1 = from.lat
    lng1 = from.lng
    lat2 = to.lat
    lng2 = to.lng
    R = 6371
    dLat = deg2rad(lat2-lat1)
    dLng = deg2rad(lng2-lng1);
    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLng/2) * Math.sin(dLng/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    dist = R * c
    return dist;


  class tutorialHandler
    ###
      Constructs the game tutorial object.
      @constructor

      @param {DOMElement} domPanels
        The set of tutorial elements active in the DOM.
    ###
    constructor: (@domPanels) ->
      @step = 0;

    ###
      Displays the panel in view.
    ###

    init: ->
      $(@domPanels[@step]).show()
      @setButton()

    ###
      Switch to the next panel.
    ###

    next: ->
      @step++
      $(@domPanels[@step]).show()
      $(@domPanels[@step - 1]).hide()
      @setButton()

    ###
      Switch to the previous panel
    ###

    prev: ->
      @step--
      $(@domPanels[@step]).show()
      $(@domPanels[@step + 1]).hide()
      @setButton()

    ###
      Generates the avaliable buttons depending on the step.
      @see this.step
    ###

    setButton: ->
      @domPanels.find('.buttonContainer').remove()
      if @step == 0
        @domPanels.append $('<div class="buttonContainer">
            <button class="prev hidden">Previous</button>
            <button class="next">Next</button>
          </div>') 
      else if @step == @domPanels.length - 1
        @domPanels.append $('<div class="buttonContainer">
          <button class="prev">Previous</button>
          <button class="next hidden">Next</button>
        </div>') 
      else
        @domPanels.append $('<div class="buttonContainer">
          <button class="prev">Previous</button>
          <button class="next">Next</button>
        </div>') 

  class gameLocation

    ###
      Constructs the game location object
      @constructor
      @param {object} position
        The position of the location.
      @param {string} 
        The name of the location.
      @param {data}
        Metadata associated with this position.
      @param {boolean} rare
        Whether if the location is a rare location or not
      @param {string} icon
        The icon to use for this location.
    ###

    constructor: (@position, @name, @data, @rare, @icon) ->
      @marker
      @value
      @travelExpense
      @travelTime

    ###
      Adds the location to the map.
      @param {object} map
        The google map element to add to.
    ###

    addTo: (map) ->
      if @icon
        marker = new google.maps.Marker({
          position: @position,
          map: map,
          icon: @icon,
          title: @name
        })
      else
        marker = new google.maps.Marker({
          position: @position,
          map: map,
          title: @name
        })
      @marker = marker
      @setListener(@marker)

    ###
      Sets event listeners on a marker
      @param {object} marker
        The google maps marker object to bind the event listener to.
    ###
    
    setListener: (marker) ->
      self = this
      marker.addListener 'click', ->
        player.moveTo(self)

      marker.addListener 'mouseover', ->
        travelDistance = parseInt(distanceTravelled(player.position, self.position))
        travelTime = travelDistance/232
        $('#locationInfoOverlay #title').text self.data.description
        $('#locationInfoOverlay #position').text 'Distance away ' + travelDistance + 'km'
        $('#locationInfoOverlay #value').text 'Potential Revenue $' + self.value
        $('#locationInfoOverlay #travelExpense').text 'Travel Expense $' + parseInt((travelDistance*0.6)/10)
        $('#locationInfoOverlay #travelTime').text 'Travel Time: at least ' + travelTime.toFixed(2) + ' Hours'
        @value = self.value

  class playerMarker extends gameLocation
    ###
      Constructs the player marker object. Extends the game location object
      @constructor
      @param {object} position
        The position of the player.
      @param {string} 
        The name of the player.
      @param {data}
        Metadata associated with this player.
      @depreciated @param {string} icon
        The icon to use for this player.
      @param {object} stats
        JSON data of the player's stats.
    ###
    constructor: (@position, @name, @data, @icon, @stats) ->
      super(@position, @name, @data, @icon)
      @playerMarker
      @preStat
      @inventory = []

    ###
      Adds the player marker to the map.
      @param {object} map
        The google map element to add to.
    ###

    initTo: (map) ->
      @playerMarker = new SlidingMarker({
        position: @position,
        map: map,
        icon: 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png',
        title: @name,
        optimized: false,
        zIndex: 100
      })

    ###
      Moves the player marker to another location and calculates the result of moving to the location.
      @param {object} location
        gameLocation object, for the player marker to move to.
    ###
    
    moveTo: (location) ->
      location.travelExpense = parseInt((distanceTravelled(this.position, location.position)*0.6)/10)
      location.travelTime = parseFloat((distanceTravelled(this.position, location.position)/232).toFixed(2))
      @position = location.position
      @playerAt = location
      @playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng))
      newStats = @stats
      newStats.CAB -= player.playerAt.travelExpense
      timeTaken = location.travelTime + Math.random()*5
      gameTime.incrementTime(timeTaken)
      gameEvents.addEvent(new event 'Moved to', gameTime.getFormatted(), location.name + ' in ' + timeTaken.toFixed(2) + ' hours')
      $('#takePic').show()
      updateMarkers()
      @updateStats(newStats)
      if gameGlobal.init.isPlus
        randEvent = gameGlobal.turnConsts.randomEvents[Math.floor(Math.random() * gameGlobal.turnConsts.randomEvents.length)]
        if randEvent.chance > Math.random() * 100 then gameEvents.addEvent randEvent else return

    ###
      Depreciates the player's inventory.
    ###

    depreciateInv: ->
      depreciation = 0
      for item in @inventory
        if item.value < 1
          return 
        else 
          depreciation += item.value - item.value*0.9
          item.value = item.value*0.9
      newStats = player.stats
      newStats.assets -= depreciation.toFixed 2
      if depreciation > 0 then gameEvents.addEvent new event 'Depreciation - ', gameTime.getFormatted(),'Photos depreciated by $' + depreciation.toFixed(2), false, true
      @updateStats(newStats)

    ###
      Updates the player stats and animates it in the DOM.
      @param {object} stats
        The new stats to update to.
    ###

    updateStats: (stats) ->
      animateText = (elem, from, to) ->
        $(current: from).animate { current: to },
          duration: 500
          step: ->
            $('#playerInfoOverlay #stats ' + elem + ' .val').text @current.toFixed()
      assets = parseInt (@stats.assets + @stats.CAB)
      workingCapital = parseInt (assets - @stats.liabilities)
      animateText '#CAB', parseInt($('#playerInfoOverlay #stats #CAB .val').text()), stats.CAB
      animateText '#liabilities', parseInt($('#playerInfoOverlay #stats #liabilities .val').text()), stats.liabilities
      animateText '#assets', parseInt($('#playerInfoOverlay #stats #assets .val').text()), assets
      animateText '#workingCapital', parseInt($('#playerInfoOverlay #stats #workingCapital .val').text()), workingCapital
      @preStat = {
        CAB: stats.CAB, 
        workingCapital: workingCapital, 
        assets: assets, 
        liabilities: stats.liabilities
      }
      if workingCapital <= -1000 && @stats.CAB <= 0
        $('#playerInfoOverlay #stats #workingCapital, #playerInfoOverlay #stats #CAB').css 'color', 'red'
      else
        $('#playerInfoOverlay #stats #workingCapital, #playerInfoOverlay #stats #CAB').css 'color', ''
        gameGlobal.turnConsts.alert = false

  class timeManager

    ###
      Constructs the time manager object.
      @constructor
      @param {array} baseTime
        The initial date/time to start the game with.
    ###

    constructor: (@baseTime) ->
      @timeCounter = 0
      @dateCounter = 0
      @monthCounter = 0
      @yearCounter = 0

    ###
      Increases the game time by hours.
      @param {integer} hours
        The hours to increase the game time by.
    ###

    incrementTime: (hours) ->
      @timeCounter += hours
      while @timeCounter >= 24
        @incrementDays(1)
        @timeCounter -= 24
        if @timeCounter < 24
          @timeCounter = @timeCounter % 24
          break

    ###
      Increases the game time by days.
      @param {integer} days
        The days to increase the game time by.
    ###
    
    incrementDays: (days) ->
      @dateCounter += days
      player.depreciateInv()
      while @dateCounter >= 30
        @incrementMonths(1)
        @dateCounter -= 30
        endTurn(@getFormatted())
        if @dateCounter < 30
          @dateCounter = @dateCounter % 30
          break

    ###
      Increases the game time by months.
      @param {integer} months
        The monthes to increase the game time by.
    ###

    incrementMonths: (months) ->
      @monthCounter += months
      while @monthCounter >= 12
        @incrementYears(1)
        @monthCounter -= 12
        if @monthCounter < 12
          @monthCounter = @monthCounter % 12
          break

    ###
      Increases the game time by years.
      @param {integer} years
        The years to increase the game time by.
    ###

    incrementYears: (years) ->
      @yearCounter += years

    ###
      Gets the current game time.
      @return
        Array containing the game time.
    ###

    getAll: ->
      return [@baseTime[0] + @yearCounter, @baseTime[1] + @monthCounter, @baseTime[2] + @dateCounter, parseInt(@baseTime[3]) + @timeCounter]

    ###
      Gets the formatted current game time.
      @return
        Stringified and formatted game time.
    ###

    getFormatted: ->
      year = @baseTime[0] + @yearCounter
      month = @baseTime[1] + @monthCounter
      date = @baseTime[2] + @dateCounter
      hours = parseInt(@baseTime[3]) + @timeCounter
      minutes = parseInt((hours - Math.floor(hours))*60)
      if date > 30
        date -= date - 30
      if String(parseInt(minutes)).length == 2 then return year + '/' + month + '/' + date + ' ' + String(Math.floor(hours)) + ':' + String(parseInt(minutes)) else return year + '/' + month + '/' + date + ' ' + String(Math.floor(hours)) + ':' + String(parseInt(minutes)) + '0'

  class eventManager

    ###
      Constructs the event manager to handles all events.
      @constructor
      @param {DOMElement} domSelector
        The DOM element to display the event on.
    ###
    constructor: (@domSelector, @domOverlay) ->
      @events = []

    ###
      Adds a event to the event manager
      @param {object} event
        The event object to add to the event manager.
    ###

    addEvent: (event) ->
      if event.time == 'currentTime' then event.time = gameTime.getFormatted()
      if event.constructor.name == 'randomEvent'
        if Math.random()*100 < event.chance then gameInsanity.updateBar(event.incInsanity)
        if event.effects
          for effectName in Object.keys(event.effects)
            newStats = player.stats[effectName] += event.effects[effectName] 
          player.updateStats(newStats)
        @domOverlay.find('.title').text event.title
        @domOverlay.find('.content').text event.content
        @domOverlay.show()
      else
        @events.push(event)
        if event.warn
          $('<div class="row">
            <p class="time">' + event.time + '</p>
            <p class="title warn">' + event.title + '</p>
            <p class="content">' + event.content + '</p>
          </div>').hide().prependTo(@domSelector).fadeIn()
        else if event.special
          $('<div class="row">
            <p class="time special">' + event.time + '</p>
            <p class="title special">' + event.title + '</p>
            <p class="content special">' + event.content + '</p>
          </div>').hide().prependTo(@domSelector).fadeIn()
        else 
          $('<div class="row">
            <p class="time">' + event.time + '</p>
            <p class="title">' + event.title + '</p>
            <p class="content">' + event.content + '</p>
          </div>').hide().prependTo(@domSelector).fadeIn()

  class playerInsanity
    constructor: (@domSelector, @initVal) ->

    updateBar: (value) ->
      #console.log value

  ###
    Processes and validates an array of data.
    @param {array} data
      The set of data to process.

    @return
      The array of processed data/
  ###

  processData = (data) ->
    processedData = []
    for item in data.result.records
      if item['dcterms:spatial']
        if item['dcterms:spatial'].split(';')[1]
          processedData.push(item)
    return processedData

  ###
    Generates google map markers from a set of data
    @param {array} data
      The set of data to generate markers from.
  ###

  generateMarkers = (data) ->
    marker = []
    i = 0
    for place in data
      lat = parseFloat(place['dcterms:spatial'].split(';')[1].split(',')[0])
      lng = parseFloat(place['dcterms:spatial'].split(';')[1].split(',')[1])
      marker[i] = new gameLocation {lat, lng}, place['dcterms:spatial'].split(';')[0], {'title': place['dc:title'], 'description': place['dc:description'], 'img': place['150_pixel_jpg']}, false
      marker[i].addTo(googleMap)
      locations.push(marker[i])
      setValue(marker[i])
      i++
    updateMarkers()

  ###
    Sets the value of a given location based on the distance from the player.
    @param {object} location
      gameLocation object to set the value by.
  ###

  setValue = (location) ->
    rare = Math.random() <= 0.05;
    if rare
      location.value = parseInt((Math.random()*distanceTravelled(player.position, location.position) + 100))
      location.rare = true
    else
      location.value = parseInt((Math.random()*distanceTravelled(player.position, location.position) + 100)/10)

  ###
    Updates the markers as the user player moves.
    @see playerMarker.prototype.moveTo()
  ###
  updateMarkers = ->
    for location in locations
      hide = Math.random() >= 0.8;
      show = Math.random() <= 0.2;
      if hide
        location.marker.setVisible(false)

  ###
    Instantiate the game components.
  ###

  gameEvents = new eventManager $('#eventLog .eventContainer'), $('#randomEventOverlay')
  gameTime = new timeManager [1939, 1, 1, 0]
  gameTutorial = new tutorialHandler $('.tutorial')
  gameInsanity = new playerInsanity $('#insanityBar'), 0

  player = new playerMarker {lat: -25.363, lng: 151.044}, 'player', {'type':'self'} ,'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  player.initTo googleMap
  player.stats = gameGlobal.init.stats
  player.updateStats player.stats

  class photographyGame

    ###
      Constructs the photography game.
      @constructor
      @param {boolean} debug
        The debug state of the game.
    ###
    constructor: (@debug) ->
      @score = 0

    ###
      Initialize the photography game.
      @param {integer} amount
        The amount of markers to initialize the game with.
    ###

    init: (amount) ->
      localInit = ->
        validData.sort ->
          return 0.5 - Math.random()
        generateMarkers(validData.slice(0, amount))
        gameTutorial.init()
        gameEvents.addEvent(new event 'Game started', gameTime.getFormatted(), '')

      if localStorage.getItem 'photographyGameData'
        validData = processData(JSON.parse(localStorage.getItem 'photographyGameData'))
        if amount > validData.length
          retrieveResources(3000).then (res) ->
            localStorage.setItem 'photographyGameData', JSON.stringify(res)
            validData = processData res
            localInit()
        else
          localInit()
      else
        retrieveResources(3000).then (res) ->
          localStorage.setItem 'photographyGameData', JSON.stringify(res)
          validData = processData res
          localInit()

  ###
    Instantiate the photography game.
  ###
  currentGame = new photographyGame false

  if getParam('diff') == 'normal'
    currentGame.init(100)
  else if  getParam('diff') == 'extended'
    currentGame.init(500)

  ###
    Displays the end game screen.
  ###
  endGame = ->
    $('#gameEnd .stat').text 'You survived for ' + gameGlobal.trackers.monthPassed + ' Months, selling ' + gameGlobal.trackers.photosSold + ' photos and making over $' + gameGlobal.trackers.moneyEarned
    currentGame.score = gameGlobal.trackers.monthPassed*gameGlobal.trackers.photosSold*gameGlobal.trackers.moneyEarned
    $('#gameEnd .score').text 'Your score: ' + currentGame.score + ' pt' 
    $('#gameEnd').show();

  ###
    Ends the month.
    @param {string} date
      The date which the month ended on.
  ###

  endTurn = (date) ->
    if gameGlobal.init.isStory && gameGlobal.trackers.monthPassed >= 6 
      $('#gameEnd h4').text 'You recieve a letter from the army. Now you can finally join the front lines.'
      $('#gameEnd .score').hide()
      endGame()
    gameGlobal.turnConsts.interest = (Math.random()*5).toFixed(2)
    gameEvents.addEvent(new event 'The month comes to an end.', date, 'Paid $' + player.stats.liabilities + ' in expenses', true)
    newStats = player.stats
    newStats.CAB -= player.stats.liabilities
    newStats.liabilities = gameGlobal.turnConsts.stdLiabilities
    player.updateStats(newStats)
    if player.preStat.workingCapital <= -1000 && player.preStat.CAB <= 0
      if gameGlobal.turnConsts.alert then endGame() else gameGlobal.trackers.monthPassed += 1
      gameGlobal.turnConsts.alert = true
    else
      gameGlobal.trackers.monthPassed += 1
    if gameGlobal.turnConsts.alert && player.preStat.workingCapital > -1000 && player.preStat.CAB > 0
      gameGlobal.turnConsts.alert = false
    for location in locations
      show = Math.random() > 0.2
      if show
        location.marker.setVisible(true)

  ###
    Displays the taking picture screen.
  ###

  $('#takePic').hide()
  $('#takePic').click ->
    $('#takingPic .section3').css 'width', (Math.floor(Math.random() * (10 + 2))) + 1 + '%'
    $('#takingPic .section2').css 'width', (Math.floor(Math.random() * (19 + 2))) + '%'
    $('#takingPic .section4').css 'width', (Math.floor(Math.random() * (19 + 2))) + '%'
    $('#takingPic .slider').css 'left', 0
    $('#takingPic .start, #takingPic .stop').prop 'disabled', false
    $('#takingPic .shotStats').hide()
    $('#takingPic').show()
    $('#takingPic .viewInv').hide()
    $('#takingPic .close').hide()
    $(this).hide()

  ###
    Starts the animation of the slider when taking the picture.
  ###

  $('#takingPic .start').click ->
    $(this).prop 'disabled', true
    $('#takingPic .slider').animate({
      'left': $('#takingPic .section1').width() + $('#takingPic .section2').width() + $('#takingPic .section3').width() + $('#takingPic .section4').width() + $('#takingPic .section5').width() + 'px';
    }, 1000, ->
      calculatePicValue()
    )

  ###
    Ends the animation of the slider when taking the picture.
  ###

  $('#takingPic .stop').click ->
    $(this).prop 'disabled', true
    $('#takingPic .slider').stop()
    $('#takingPic .close').show()
    calculatePicValue()

  ###
    Calculates the value of the picture based on the slider position.
  ###
      
  calculatePicValue = ->
    $('#takingPic .viewInv').show()
    $('#takingPic .shotStats').show();
    multiplier = 1
    quailty = 1
    sliderPosition = parseInt($('#takingPic .slider').css('left'), 10)
    inBlue = ($('#takingPic .section1').position().left + $('#takingPic .section1').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section5').position().left
    inGreen = ($('#takingPic .section2').position().left + $('#takingPic .section2').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section4').position().left
    if inBlue && inGreen
      multiplier = 1.4
      quailty = 0
      $('.shotStats').text 'You take a high quailty photo, this will surely sell for more!'
    else if inBlue
      $('.shotStats').text 'You take a average photo.'    
    else
      multiplier = 0.8
      quailty = 2
      $('.shotStats').text 'The shot comes out all smudged...'
    addShotToInv(multiplier, quailty)
    timeTaken = Math.floor(Math.random()*10) + 24
    gameTime.incrementTime(timeTaken)
    gameEvents.addEvent(new event 'Taking Pictures', gameTime.getFormatted(), 'You spend some time around ' + player.playerAt.name + '. '+ timeTaken + ' hours later, you finally take a picture of value.')
    if player.playerAt.rare 
      gameEvents.addEvent(new event 'Rare Picture -', gameTime.getFormatted(), 'You take a rare picture.', true)
      if !gameGlobal.init.isStory
        if $('#savePicOverlay .img img').length == 0
          $('#savePicOverlay .img').append $('<img src="' + player.playerAt.data.img + '">')
        else
          $('#savePicOverlay .img img').attr 'src', player.playerAt.data.img
        $('#savePicOverlay .title').text player.playerAt.data.title
        $('#savePicOverlay #confirmSavePic').prop 'disabled', false
        $('#savePicOverlay').show()

  ###
    Instantiate the game photo object and adds a photographic shot to the inventory
    @param {integer} multiplier
      The scalar to multiple the value of the shot by.
    @param {integer} quailty
      The quailty of the picture.
  ###

  addShotToInv = (multiplier, quailty) ->
    photoValue = player.playerAt.value*multiplier
    shotTaken = new gamePhoto photoValue, false, player.playerAt.data.img, player.playerAt.data.title, quailty
    player.inventory.push(shotTaken)
    player.playerAt.marker.setVisible(false)
    newStats = player.stats
    newStats.assets += photoValue
    newStats.workingCapital -= player.playerAt.travelExpense/2
    player.updateStats(newStats)

  ###
    Displays the player inventory and closes previous element's parent.
  ###

  $('.viewInv').click ->
    closeParent(this)
    displayInv()

  ###
    Displays the player inventory.
  ###

  $('#checkInv').click ->
    displayInv()
  
  ###
    Generates the player inventory.
  ###
    
  displayInv = ->
    $('#blockOverlay').show()
    $('#inventory .photoContainer').remove()
    $('#inventory').show()
    potentialValue = 0;
    sellableValue = 0;
    for item in player.inventory
      pictureContainer = $('<div class="photoContainer"></div>')
      picture = $('
      <div class="crop">
        <img class="photo" src="' + item.img + '"/>
      </div>').css('filter', 'blur('+ item.quailty + 'px')
      picture.appendTo(pictureContainer)
      if !item.washed
        pictureContainer.appendTo($('#inventory .cameraRoll'))
        potentialValue += item.value
      else
        pictureContainer.appendTo($('#inventory .washedPics'))
        sellableValue += item.value
      $('<aside>
        <p>Value $' + parseInt(item.value) + '</p>
        <p>' + item.title + '</p>
      </aside>').appendTo(pictureContainer)
    
    $('#rollValue').text('Total value $' + parseInt(potentialValue + sellableValue))
    $('#sellableValue').text('Sellable Pictures value $' + parseInt(sellableValue))

  ###
    Displays the waiting screen.
  ###

  $('#wait').click ->
    if $('#waitTimeInput').val() == '' then $('#waitTimeInput').parent().find('button.confirm').prop 'disabled', true
    $('#waitInfo').show()

  ###
    Waits and passes the game time.
  ###

  $('#confirmWait').click ->
    gameTime.incrementDays(parseInt($('#waitTimeInput').val()))
    if parseInt($('#waitTimeInput').val()) != 1 then gameEvents.addEvent(new event '', gameTime.getFormatted(), 'You wait ' + $('#waitTimeInput').val() + ' days') else gameEvents.addEvent(new event '', gameTime.getFormatted(), 'You wait ' + $('#waitTimeInput').val() + ' day')
    validData.sort ->
      return 0.5 - Math.random()
    generateMarkers(validData.slice(0, parseInt($('#waitTimeInput').val())/2))
    for location in locations
      show = Math.floor(Math.random() * (30)) <= parseInt($('#waitTimeInput').val())/2
      if show
        location.marker.setVisible true

  ###
    Displays the pictures avaliable for washing.
  ###

  $('#washPic').click ->
    notWashed = []
    for item in player.inventory
      if !item.washed then notWashed.push(item)
    if notWashed.length == 0
      $('#washPicOverlay p').text 'There are no pictures to wash.'
      $('#washPicOverlay').show()
      $('#washPicOverlay #confirmWashPic').hide()
    else
      for item in player.inventory
        item.washed = true
      $('#washPicOverlay p').text 'Washing photos takes ' + gameGlobal.turnConsts.pictureWashingTime + ' days. Proceed?'
      $('#washPicOverlay').show()
      $('#washPicOverlay #confirmWashPic').show()

  ###
    Washes all unwashed pictures in the player's inventory.
  ###

  $('#confirmWashPic').click ->
    gameTime.incrementTime(10*Math.random())
    gameTime.incrementDays(gameGlobal.turnConsts.pictureWashingTime)
    gameEvents.addEvent(new event 'Washed pictures.', gameTime.getFormatted(), 'You wash all pictures in your camera.' )

  ###
    Displays the take loan screen.
  ###

  $('#takeLoan').click ->
    $('#IR').text('Current interest rate ' + gameGlobal.turnConsts.interest + '%')
    if $('#loanInput').val() == '' then $('#loanInput').parent().find('button.confirm').prop 'disabled', true
    $('#loanOverlay').show()

  ###
    Confirms the loan to the player.
  ###

  $('#confirmLoan').click ->
    newStats = player.stats
    newStats.liabilities += parseInt($('#loanInput').val())+parseInt($('#loanInput').val())*(gameGlobal.turnConsts.interest/10)
    newStats.CAB += parseInt($('#loanInput').val())
    player.updateStats(newStats)
    gameEvents.addEvent(new event 'Bank loan.', gameTime.getFormatted(), 'You take a bank loan of $' + parseInt($('#loanInput').val()))
  
  ###
    Validates the input to ensure the input is a number and non empty.
  ###
  
  $('#loanInput, #waitTimeInput').keyup ->
    if !$.isNumeric($(this).val()) || $(this).val() == ''
      $(this).parent().find('.err').text '*Input must be a number'
      $(this).parent().find('button.confirm').prop 'disabled', true
    else
      $(this).parent().find('.err').text ''
      $(this).parent().find('button.confirm').prop 'disabled', false

  ###
    Displays the sell pictures screen.
  ###

  $('#sellPic').click ->
    sellablePhotos = 0
    photosValue = 0
    for photo in player.inventory
      if photo.washed
        sellablePhotos += 1
        photosValue += photo.value
    $('#soldInfoOverlay p').text 'Potential Earnings $' + parseInt(photosValue) + ' from ' + sellablePhotos + ' Photo/s'
    if sellablePhotos == 0 then $('#soldInfoOverlay button').hide() else $('#soldInfoOverlay button').show()
    $('#soldInfoOverlay').show()

  ###
    Sells the washed photos in the player's inventory.
  ###

  $('#sellPhotos').click ->
    photosSold = 0
    earningsEst = 0
    earningsAct = 0
    newInventory = []
    newStats = player.stats
    for photo in player.inventory
      if photo.washed
        earningsAct += parseInt(photo.value + (photo.value*Math.random()))
        earningsEst += photo.value
        photosSold += 1
        gameGlobal.trackers.photosSold += 1
        gameGlobal.trackers.moneyEarned += earningsAct
      else
        newInventory.push(photo)
    timeTaken = ((Math.random()*2)+1)*photosSold
    player.inventory = newInventory
    newStats.CAB += earningsAct
    newStats.assets -= earningsEst
    player.updateStats(newStats)
    gameTime.incrementDays(parseInt(timeTaken))
    if parseInt(timeTaken) == 1 then gameEvents.addEvent(new event 'Selling Pictures.', gameTime.getFormatted(), 'It took ' + parseInt(timeTaken) + ' day to finally sell everything. Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s.') else gameEvents.addEvent(new event 'Selling Pictures.', gameTime.getFormatted(), 'It took ' + parseInt(timeTaken) + ' days to finally sell everything. Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s.')

  ###
    Blocks the game when a overlay/interface is active.
  ###

  $('#actions button').click ->
    $('#blockOverlay').show()

  ###
    Closes the overlay.
  ###

  $('.confirm, .close').click ->
    closeParent(this)

  ###
    Saves the DOM element to the player's collection.
  ###

  $('#confirmSavePic').click ->
    saveItem $('#savePicOverlay .img img').attr('src'), $('#savePicOverlay .title').text()
    $(this).prop 'disabled', true

  ###
    Closes the parent of the original DOM element
    @param {DOMElement} self
      The element whose parent should be hidden.
  ###

  closeParent = (self) ->
    $(self).parent().hide()
    $('#blockOverlay').hide()
    $('.status').text ''

  ###
    jQuery UI draggable handler.
  ###

  $('#actions').draggable()

  $('#actions').mousedown ->
    $('#actions p').text 'Actions'

  ###
    Saves the current user score.
  ###

  $('#saveScore').click ->
    currentGame.saveScore()

  ###
    Binds the generated buttons to the click event.
  ###

  $('body').on 'click', '.tutorial .next', ->
    gameTutorial.next()
  
  $('body').on 'click', '.tutorial .prev', ->
    gameTutorial.prev()
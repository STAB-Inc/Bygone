jQuery(document).ready ->

  #Game globals
  locations = []
  
  gameGlobal = {
    trackers: {
      monthPassed: 0,
      photosSold: 0,
      moneyEarned: 0
    },
    turnConsts: {
      interest: 1.5,
      pictureWashingTime: 14
    }
  }

  deg2rad = (deg) ->
    return deg * (Math.PI/180)

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

  class location
    constructor: (@position, @name, @data, @rare, @icon ) ->
      @marker
      @value
      @travelExpense
      @travelTime

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
    
    setListener: (marker) ->
      self = this
      marker.addListener 'click', ->
        mark.moveTo(self)

      marker.addListener 'mouseover', ->
        #$('#locationInfoOverlay img').attr 'src', self.data.img
        #$('#locationInfoOverlay #description').text self.data.description
        travelDistance = parseInt(distanceTravelled(mark.position, self.position))
        travelTime = travelDistance/232
        $('#locationInfoOverlay #title').text self.data.description
        $('#locationInfoOverlay #position').text 'Distance away ' + travelDistance + 'km'
        $('#locationInfoOverlay #value').text 'Potential Revenue $' + self.value
        $('#locationInfoOverlay #travelExpense').text 'Travel Expense $' + parseInt((travelDistance*0.6)/10)
        $('#locationInfoOverlay #travelTime').text 'Travel Time: at least ' + travelTime.toFixed(2) + ' Hours'
        @value = self.value

  class player extends location
    constructor: (@position, @name, @data, @icon, @stats) ->
      super(@position, @name, @data, @icon)
      @playerMarker
      @inventory = []

    initTo: (map) ->
      @playerMarker = new google.maps.Marker({
        position: @position,
        map: map,
        icon: 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png',
        title: @name,
        optimized: false,
        zIndex: 100
      })
    
    moveTo: (location) ->
      location.travelExpense = parseInt((distanceTravelled(this.position, location.position)*0.6)/10)
      location.travelTime = parseFloat((distanceTravelled(this.position, location.position)/232).toFixed(2))
      @position = location.position
      @playerAt = location
      @playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng))
      newStats = @stats
      newStats.CAB -= mark.playerAt.travelExpense
      timeTaken = location.travelTime + Math.random()*5
      gameTime.incrementTime(timeTaken)
      gameEvents.addEvent(new event 'Moved to', gameTime.getFormatted(), location.name + ' in ' + timeTaken.toFixed(2) + ' hours')
      $('#takePic').show()
      updateMarkers()
      @updateStats(newStats)

    updateStats: (stats) ->
      @stats = stats
      assets = parseInt(@stats.assets + @stats.CAB)
      workingCapital = parseInt(assets - @stats.liabilities)
      $('#playerInfoOverlay #stats #CAB').text 'Cash at Bank $' + parseInt(@stats.CAB)
      $('#playerInfoOverlay #stats #liabilities').text 'Current Liabilities $' + parseInt(@stats.liabilities)
      $('#playerInfoOverlay #stats #assets').text 'Current Assets $' + assets
      $('#playerInfoOverlay #stats #workingCapital').text 'Working Capital $' + workingCapital
      if workingCapital <= -1000 && @stats.CAB <= 0
        endGame()

  class timeManager
    constructor: (@baseTime) ->
      @timeCounter = 0
      @dateCounter = 0
      @monthCounter = 0
      @yearCounter = 0

    incrementTime: (hours) ->
      @timeCounter += hours
      while @timeCounter >= 24
        @incrementDays(1)
        @timeCounter -= 24
        if @timeCounter < 24
          @timeCounter = @timeCounter % 24
          break
    
    incrementDays: (days) ->
      @dateCounter += days
      while @dateCounter >= 30
        @incrementMonths(1)
        @dateCounter -= 30
        endTurn(@getFormatted())
        if @dateCounter < 30
          @dateCounter = @dateCounter % 30
          break

    incrementMonths: (months) ->
      @monthCounter += months
      while @monthCounter >= 12
        @incrementYears(1)
        @monthCounter -= 12
        if @monthCounter < 12
          @monthCounter = @monthCounter % 12
          break

    incrementYears: (years) ->
      @yearCounter += years

    getAll: ->
      return [@baseTime[0] + @yearCounter, @baseTime[1] + @monthCounter, @baseTime[2] + @dateCounter, parseInt(@baseTime[3]) + @timeCounter]

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
    constructor: (@domSelector) ->
      @events = []

    addEvent: (event) ->
      @events.push(event)
      if event.special
        $('<div class="row">
          <p class="time special">' + event.time + '</p>
          <p class="title special">' + event.title + '</p>
          <p class="content special">' + event.content + '</p>
        </div>').prependTo(@domSelector)
      else 
        $('<div class="row">
          <p class="time">' + event.time + '</p>
          <p class="title">' + event.title + '</p>
          <p class="content">' + event.content + '</p>
        </div>').prependTo(@domSelector)

  class event
    constructor: (@title, @time, @content, @special=false) ->

  class gamePhoto
    constructor: (@value, @washed, @img, @title, @quailty) ->

  processData = (data) ->
    processedData = []
    for item in data.result.records
      if item['dcterms:spatial']
        if item['dcterms:spatial'].split(';')[1]
          processedData.push(item)
    return processedData

  generateMarkers = (data) ->
    marker = []
    i = 0
    for place in data
      lat = parseFloat(place['dcterms:spatial'].split(';')[1].split(',')[0])
      lng = parseFloat(place['dcterms:spatial'].split(';')[1].split(',')[1])
      marker[i] = new location {lat, lng}, place['dcterms:spatial'].split(';')[0], {'title': place['dc:title'], 'description': place['dc:description'], 'img': place['150_pixel_jpg']}, false
      marker[i].addTo(googleMap)
      locations.push(marker[i])
      setValue(marker[i])
      i++
    updateMarkers()
    return

  setValue = (location) ->
    rare = Math.random() <= 0.1;
    if rare
      location.value = parseInt((Math.random()*distanceTravelled(mark.position, location.position) + 100))
      location.rare = true
    else
      location.value = parseInt((Math.random()*distanceTravelled(mark.position, location.position) + 100)/10)

  updateMarkers = ->
    for location in locations
      hide = Math.random() >= 0.8;
      show = Math.random() <= 0.2;
      if hide
        location.marker.setVisible(false)

  

  gameEvents = new eventManager $('#eventLog .eventContainer')
  gameTime = new timeManager [1939, 1, 1, 0]

  mark = new player {lat: -25.363, lng: 151.044}, 'Mark', {'type':'self'} ,'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  mark.initTo(googleMap)
  mark.updateStats({'CAB':1000, 'workingCapital': 0, 'assets': 0, 'liabilities': 300 })

  class photographyGame
    constructor: (@debug) ->

    init: (amount) ->
      if localStorage.getItem 'photographyGameData'
        validData = processData(JSON.parse(localStorage.getItem 'photographyGameData'))
        if amount > validData.length
          retrieveResources(1000).then (res) ->
            localStorage.setItem 'photographyGameData', JSON.stringify(res)
            validData = processData res
      else
        retrieveResources(1000).then (res) ->
          localStorage.setItem 'photographyGameData', JSON.stringify(res)
          validData = processData res

      validData.sort ->
        return 0.5 - Math.random()
      generateMarkers(validData.slice(0, amount))
      gameEvents.addEvent(new event 'Game started', gameTime.getFormatted(), '')

  currentGame = new photographyGame false
  currentGame.init(100)

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

  endGame = ->
    $('#gameEnd p').text 'You survived for ' + gameGlobal.trackers.monthPassed + ' Months, selling ' + gameGlobal.trackers.photosSold + ' photos and making over $' + gameGlobal.trackers.moneyEarned
    $('#gameEnd').show();

  endTurn = (date) ->
    gameGlobal.trackers.monthPassed += 1
    gameGlobal.turnConsts.interest = (Math.random()*5).toFixed(2)
    newStats = mark.stats
    newStats.CAB -= mark.stats.liabilities
    mark.updateStats(newStats)
    gameEvents.addEvent(new event 'The month comes to an end.', date, 'Paid $' + mark.stats.liabilities + ' in expenses', true)
    for location in locations
      show = Math.random() > 0.2
      if show
        location.marker.setVisible(true)

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
    
  addShotToInv = (multiplier, quailty) ->
    photoValue = mark.playerAt.value*multiplier
    shotTaken = new gamePhoto photoValue, false, mark.playerAt.data.img, mark.playerAt.data.title, quailty
    mark.inventory.push(shotTaken)
    mark.playerAt.marker.setVisible(false)
    newStats = mark.stats
    newStats.assets += photoValue
    newStats.workingCapital -= mark.playerAt.travelExpense/2
    mark.updateStats(newStats)

  $('#takingPic .start').click ->
    $(this).prop 'disabled', true
    $('#takingPic .slider').animate({
      'left': $('#takingPic .section1').width() + $('#takingPic .section2').width() + $('#takingPic .section3').width() + $('#takingPic .section4').width() + $('#takingPic .section5').width() + 'px';
    }, 1000, ->
      calculatePicValue()
    )

  $('#takingPic .stop').click ->
    $(this).prop 'disabled', true
    $('#takingPic .slider').stop()
    $('#takingPic .close').show()
    calculatePicValue()
      
  calculatePicValue = ->
    $('#takingPic .viewInv').show()
    $('#takingPic .shotStats').show();
    multiplier = 1
    quailty = 1
    sliderPosition = parseInt($('#takingPic .slider').css('left'), 10)
    inBlue = ($('#takingPic .section1').position().left + $('#takingPic .section1').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section5').position().left
    inGreen = ($('#takingPic .section2').position().left + $('#takingPic .section2').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section4').position().left
    if inBlue && inGreen
      multiplier = 1.2
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
    gameEvents.addEvent(new event 'Taking Pictures', gameTime.getFormatted(), 'You spend some time around ' + mark.playerAt.name + '. '+ timeTaken + ' hours later, you finally take a picture of value.')
    if mark.playerAt.rare then gameEvents.addEvent(new event 'Rare Picture.', gameTime.getFormatted(), 'You take a rare picture.', true)

  $('.viewInv').click ->
    closeParent(this)
    displayInv()

  $('#checkInv').click ->
    displayInv()
    
  displayInv = ->
    $('#blockOverlay').show()
    $('#inventory .photoContainer').remove()
    $('#inventory').show()
    potentialValue = 0;
    sellableValue = 0;
    for item in mark.inventory
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

  $('#wait').click ->
    $('#waitInfo').show()

  $('#confirmWait').click ->
    gameTime.incrementDays(parseInt($('#waitTimeInput').val()))
    if parseInt($('#waitTimeInput').val()) != 1 then gameEvents.addEvent(new event '', gameTime.getFormatted(), 'You wait ' + $('#waitTimeInput').val() + ' days') else gameEvents.addEvent(new event '', gameTime.getFormatted(), 'You wait ' + $('#waitTimeInput').val() + ' day')
    for location in locations
      show = Math.floor(Math.random() * (30)) <= parseInt($('#waitTimeInput').val())/2
      if show
        location.marker.setVisible(true)

  $('#washPic').click ->
    notWashed = []
    for item in mark.inventory
      if !item.washed then notWashed.push(item)
    if notWashed.length == 0
      $('#washPicOverlay p').text 'There are no pictures to wash.'
      $('#washPicOverlay').show()
      $('#washPicOverlay #confirmWashPic').hide()
    else
      for item in mark.inventory
        item.washed = true
      $('#washPicOverlay p').text 'Washing photos takes ' + gameGlobal.turnConsts.pictureWashingTime + ' days. Proceed?'
      $('#washPicOverlay').show()
      $('#washPicOverlay #confirmWashPic').show()

  $('#confirmWashPic').click ->
    gameTime.incrementTime(10*Math.random())
    gameTime.incrementDays(gameGlobal.turnConsts.pictureWashingTime)
    gameEvents.addEvent(new event 'Washed pictures.', gameTime.getFormatted(), 'You wash all pictures in your camera.' )

  $('#takeLoan').click ->
    $('#IR').text('Current interest rate ' + gameGlobal.turnConsts.interest + '%')
    $('#loanOverlay').show()

  $('#confirmLoan').click ->
    newStats = mark.stats
    newStats.liabilities += parseInt($('#loanInput').val())+parseInt($('#loanInput').val())*(gameGlobal.turnConsts.interest/10)
    newStats.CAB += parseInt($('#loanInput').val())
    mark.updateStats(newStats)

  $('#sellPic').click ->
    sellablePhotos = 0
    photosValue = 0
    for photo in mark.inventory
      if photo.washed
        sellablePhotos += 1
        photosValue += photo.value
    $('#soldInfoOverlay p').text 'Potential Earnings $' + parseInt(photosValue) + ' from ' + sellablePhotos + ' Photo/s'
    if sellablePhotos == 0 then $('#soldInfoOverlay button').hide() else $('#soldInfoOverlay button').show()
    $('#soldInfoOverlay').show()

  $('#sellPhotos').click ->
    photosSold = 0
    earningsEst = 0
    earningsAct = 0
    newInventory = []
    newStats = mark.stats
    for photo in mark.inventory
      if photo.washed
        earningsAct += parseInt(photo.value + (photo.value*Math.random()))
        earningsEst += photo.value
        photosSold += 1
        gameGlobal.trackers.photosSold += 1
        gameGlobal.trackers.moneyEarned += earningsAct
      else
        newInventory.push(photo)
    timeTaken = ((Math.random()*2)+1)*photosSold
    mark.inventory = newInventory
    newStats.CAB += earningsAct
    newStats.assets -= earningsEst
    mark.updateStats(newStats)
    gameTime.incrementDays(parseInt(timeTaken))
    if parseInt(timeTaken) == 1 then gameEvents.addEvent(new event 'Selling Pictures.', gameTime.getFormatted(), 'It took ' + parseInt(timeTaken) + ' day to finally sell everything. Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s.') else gameEvents.addEvent(new event 'Selling Pictures.', gameTime.getFormatted(), 'It took ' + parseInt(timeTaken) + ' days to finally sell everything. Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s.')

  $('#actions button').click ->
    $('#blockOverlay').show()

  $('.confirm, .close').click ->
    closeParent(this)

  closeParent = (self) ->
    $(self).parent().hide()
    $('#blockOverlay').hide()

  $('#actions').draggable()

  $('#actions').mousedown ->
    $('#actions p').text 'Actions'
    
  return
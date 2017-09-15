jQuery(document).ready ->

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
    constructor: (@position, @name, @data, @icon) ->
      @marker
      @value
      @travelExpense

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
        $('#locationInfoOverlay #title').text self.data.title
        #$('#locationInfoOverlay #description').text self.data.description
        $('#locationInfoOverlay #position').text 'Distance away ' + parseInt(distanceTravelled(mark.position, self.position)) + 'km'
        $('#locationInfoOverlay #value').text 'Potential Revenue $' + self.value
        $('#locationInfoOverlay #travelExpense').text 'Travel Expense $' + parseInt((distanceTravelled(mark.position, self.position)*0.6)/10)
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
        icon: @icon,
        title: @name,
        optimized: false,
        zIndex: 100
      })
    
    moveTo: (location) ->
      #console.log(location)
      #console.log("current position", this.position, "new position", location.position, "distance travelled", distanceTravelled(this.position, location.position) + 'km')
      location.travelExpense = parseInt((distanceTravelled(this.position, location.position)*0.6)/10)
      @position = location.position
      @playerAt = location
      @playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng))
      updateMarkers()
      $('#takePic').show()
      newStats = @stats
      newStats.CAB -= mark.playerAt.travelExpense
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

  class photo
    constructor: (@value, @washed, @img, @title) ->

  class photographyGame
    constructor: (@debug) ->

    init: ->
      retrieveResources(100).then (res) ->
        generateMarkers(processData(res))

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

  #Game Globals
  currentGame = new photographyGame false
  currentGame.init()

  mark = new player {lat: -25.363, lng: 151.044}, 'Mark', {'type':'self'} ,'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  mark.initTo(googleMap)
  mark.updateStats({'CAB':1000, 'workingCapital': 0, 'assets': 0, 'liabilities': 300 })
  
  locations = []
  
  gameGlobal = {
    trackers: {
      monthPassed: 0,
      photosSold: 0,
      moneyEarned: 0
    },
    turnConsts: {
      interest: 1.5
    }
  }

  endGame = ->
    $('#gameEnd p').text 'You survived for ' + gameGlobal.trackers.monthPassed + ' Months, selling ' + gameGlobal.trackers.photosSold + ' photos and making over $' + gameGlobal.trackers.moneyEarned
    $('#gameEnd').show();
  
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
      marker[i] = new location {lat, lng}, place[0], {'title': place['dc:title'], 'description': place['dc:description'], 'img': place['150_pixel_jpg']}
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
    else
      location.value = parseInt((Math.random()*distanceTravelled(mark.position, location.position) + 100)/10)

  updateMarkers = ->
    for location in locations
      hide = Math.random() >= 0.8;
      show = Math.random() <= 0.2;
      if hide
        location.marker.setVisible(false)

  endTurn = ->
    gameGlobal.trackers.monthPassed += 1
    gameGlobal.turnConsts.interest = (Math.random()*5).toFixed(2)
    newStats = mark.stats
    newStats.CAB -= mark.stats.liabilities
    mark.updateStats(newStats)
    for location in locations
      location.marker.setVisible(true)
  
  $('#takePic').click ->
    $('#takingPic .section3').css 'width', (Math.floor(Math.random() * (10 + 2))) + 1 + '%'
    $('#takingPic .section2').css 'width', (Math.floor(Math.random() * (19 + 2))) + '%'
    $('#takingPic .section4').css 'width', (Math.floor(Math.random() * (19 + 2))) + '%'
    $('#takingPic .slider').css 'left', 0
    $('#takingPic .start, #takingPic .stop').prop 'disabled', false
    $('#takingPic .shotStats').hide()
    $('#takingPic').show()
    $('#takingPic .viewInv').hide()
    $(this).hide()
    
  addShotToInv = (multiplier) ->
    photoValue = mark.playerAt.value*multiplier
    shotTaken = new photo photoValue, false, mark.playerAt.data.img, mark.playerAt.data.title
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
    calculatePicValue()
      
  calculatePicValue = ->
    $('#takingPic .viewInv').show()
    $('#takingPic .shotStats').show();
    multiplier = 1
    sliderPosition = parseInt($('#takingPic .slider').css('left'), 10)
    inBlue = ($('#takingPic .section1').position().left + $('#takingPic .section1').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section5').position().left
    inGreen = ($('#takingPic .section2').position().left + $('#takingPic .section2').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section4').position().left
    if inBlue && inGreen
      multiplier = 1.2
      $('.shotStats').text 'You take a high quailty photo, this will surely sell for more!'
    else if inBlue
      $('.shotStats').text 'You take a average photo.'    
    else
      multiplier = 0.8
      $('.shotStats').text 'The shot comes out all smudged...'
    addShotToInv(multiplier)

  $('.viewInv').click ->
    closeParent(this)
    displayInv()

  $('#checkInv').click ->
    displayInv()
    
  displayInv = ->
    $('#blockOverlay').show()
    $('#inventory .photo').remove()
    $('#inventory').show()
    potentialValue = 0;
    sellableValue = 0;
    for item in mark.inventory
      if !item.washed
        $('<img class="photo" src=' + item.img + '" value="' + item.value + '"/>').appendTo($('#inventory .cameraRoll'))
        potentialValue += item.value
      else
        $('<img class="photo" src=' + item.img + '" value="' + item.value + '"/>').appendTo($('#inventory .washedPics'))
        sellableValue += item.value
    $('#rollValue').text('Total value $' + parseInt(potentialValue + sellableValue))
    $('#sellableValue').text('Sellable Pictures value $' + parseInt(sellableValue))

  $('#endTurn').click ->
    $('#endTurnInfo p').text 'End this month?'
    $('#endTurnInfo').show()

  $('#confirmEndTurn').click ->
    endTurn()

  $('#washPic').click ->
    if mark.inventory.length == 0
      alert('There are no pictures to wash')
    else
      for item in mark.inventory
        item.washed = true
      $('#endTurnInfo p').text 'Washing photos ends this month. End this month?'
      $('#endTurnInfo').show()

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
    $('#soldInfoOverlay p').text 'Potential Earnings $' + photosValue + ' from ' + sellablePhotos + ' Photo/s'
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
    mark.inventory = newInventory
    newStats.CAB += earningsAct
    newStats.assets -= earningsEst
    mark.updateStats(newStats)
    $('#soldInfoOverlay p').text 'Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s'

  $('.confirm, .close').click ->
    closeParent(this)

  closeParent = (self) ->
    $(self).parent().hide()
    $('#blockOverlay').hide()

  $('#actions').draggable()

  $('#actions').mousedown ->
    $('#actions p').text 'Actions'
    
  return
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

  class photographyGame
    constructor: (@debug, @map) ->

    init: () ->

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
        $('#infoOverlay img').attr 'src', self.data.img
        $('#infoOverlay #title').text self.data.title
        $('#infoOverlay #description').text self.data.description
        $('#infoOverlay #position').text 'Distance away ' + parseInt(distanceTravelled(mark.position, self.position)) + 'km'
        $('#infoOverlay #value').text 'Potential Revenue $' + self.value
        $('#infoOverlay #travelExpense').text 'Travel Expense $' + parseInt((distanceTravelled(mark.position, self.position)*0.6)/10)
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
      console.log(location)
      console.log("current position", this.position, "new position", location.position, "distance travelled", distanceTravelled(this.position, location.position) + 'km')
      location.travelExpense = parseInt((distanceTravelled(this.position, location.position)*0.6)/10)
      @position = location.position
      @playerAt = location
      @playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng))
      updateMarkers()
      $('#takePic').show()
      newStats = @stats
      newStats.workingCapital -= mark.playerAt.travelExpense
      @updateStats(newStats)

    updateStats: (stats) ->
      @stats = stats
      $('#infoOverlay #stats #workingCapital').text 'Working Capital $' + parseInt(@stats.workingCapital)
      $('#infoOverlay #stats #capital').text 'Capital $' + parseInt((@stats.assets - @stats.liabilities))
      $('#infoOverlay #stats #assets').text 'Current Assets $' + parseInt(@stats.assets)
      $('#infoOverlay #stats #liabilities').text 'Current Liabilities $' + parseInt(@stats.liabilities)

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

  class photo
    constructor: (@value, @washed, @img, @title) ->

  processData = (data) ->
    processedData = []
    for item in data.result.records
      if item['dcterms:spatial']
        if item['dcterms:spatial'].split(';')[1]
          processedData.push(item)
    return processedData

  locations = []
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

  mark = new player {lat: -25.363, lng: 151.044}, 'Mark', {'type':'self'} ,'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  mark.initTo(googleMap)
  mark.updateStats({'workingCapital':1000, 'assets': 0, 'liabilities': 300 })

  retrieveResources(parseInt(Math.random() * (100 - 20) + 20)).then (res) ->
    generateMarkers(processData(res))

  updateMarkers = ->
    for location in locations
      hide = Math.random() >= 0.8;
      show = Math.random() <= 0.2;
      if hide
        location.marker.setVisible(false)

  interest = 1.5
  endTurn = ->
    newStats = mark.stats
    newStats.workingCapital -= mark.stats.liabilities
    mark.updateStats(newStats)
    for location in locations
      location.marker.setVisible(true)
    interest = (Math.random()*5).toFixed(2)
    console.log interest
  
  $('#takePic').click ->
    shotTaken = new photo mark.playerAt.value, false, mark.playerAt.data.img, mark.playerAt.data.title
    mark.inventory.push(shotTaken)
    mark.playerAt.marker.setVisible(false)
    newStats = mark.stats
    newStats.assets += mark.playerAt.value
    newStats.workingCapital -= mark.playerAt.travelExpense/2
    mark.updateStats(newStats)
    $('#takePic').hide()

  
  $('#checkInv').click ->
    $('#inventory').show()
    $('#inventory .photo').remove()
    value = 0
    for item in mark.inventory
      $('<img class="photo" src=' + item.img + '" value="' + item.value + '"/>').appendTo($('#inventory'))
      value += item.value
    $('#invValue').text('Photo value $' + value)

  $('.close').click ->
    $(this).parent().hide()
    
  $('#endTurn').click ->
    endTurn()

  $('#washPic').click ->
    if mark.inventory.length == 0
      alert('There are no pictures to wash')
    else
      newStats = mark.stats
      totalValue = 0
      for item in mark.inventory
        totalValue += item.value
      newStats.workingCapital += totalValue
      newStats.assets -= totalValue
      mark.updateStats(newStats)
      mark.inventory = []
      endTurn()

  $('#takeLoan').click ->
    $('#IR').text('Current interest rate '+interest+'%')
    $('#loanOverlay').show()

  $('#confirmLoan').click ->
    console.log $('#loanInput').val(), parseInt($('#loanInput').val())*(interest/10)
    newStats = mark.stats
    newStats.liabilities += parseInt($('#loanInput').val())+parseInt($('#loanInput').val())*(interest/10)
    newStats.workingCapital += parseInt($('#loanInput').val())
    console.log typeof(newStats.workingCapital)
    mark.updateStats(newStats)

  return
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
        $('#infoOverlay #description').text self.data.description
        $('#infoOverlay #position').text 'Distance away ' + parseInt(distanceTravelled(mark.position, self.position)) + 'km'
        $('#infoOverlay #value').text 'Potential Revenue $' + self.value
        $('#infoOverlay #travelExpense').text 'Travel Expense $' + parseInt(distanceTravelled(mark.position, self.position)*0.8)
        @value = self.value
        @travelExpense = parseInt(distanceTravelled(mark.position, self.position)*0.6)

  class player extends location
    constructor: (@position, @name, @data, @icon, @stats) ->
      super(@position, @name, @data, @icon)
      @playerMarker

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
      console.log("current position", this.position, "new position", location.position, "distance travelled", distanceTravelled(this.position, location.position) + 'km')
      @position = location.position
      @playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng))
      updateMarkers()

    updateStats: (stats) ->
      @stats = stats
      $('#infoOverlay #stats #workingCapital').text 'Working Capital $' + @stats.workingCapital
      $('#infoOverlay #stats #capital').text 'Capital $' + @stats.capital
      $('#infoOverlay #stats #assets').text 'Assets $' + @stats.assets
      $('#infoOverlay #stats #liabilities').text 'Liabilities $' + @stats.liabilities

  retrieveResources = (amount) ->
    reqParam = {
      resource_id: '9913b881-d76d-43f5-acd6-3541a130853d',
      limit: amount
    }
    $.ajax {
      url: 'http://data.gov.au/api/action/datastore_search',
      data: reqParam,
      dataType: 'jsonp',
      cache: true
  }

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
      i++
    return

  setValue = (location) ->
    location.value = parseInt(Math.random()*distanceTravelled(mark.position, location.position) + 100)

  mark = new player {lat: -25.363, lng: 151.044}, 'Mark', {'type':'self'} ,'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  mark.initTo(googleMap)
  mark.updateStats({'workingCapital':1000, 'capital':700, 'assets': 200, 'liabilities': 500 })

  retrieveResources(parseInt(Math.random() * (100 - 20) + 20)).then (res) ->
    generateMarkers(processData(res))

  updateMarkers = ->
    for location in locations
      hide = Math.random() >= 0.8;
      show = Math.random() <= 0.2;
      setValue(location)
      if hide
        location.marker.setVisible(false)
      if show
        location.marker.setVisible(true)
  
  $('#gm').click ->
    removeMarkers()

  return
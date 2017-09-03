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
    constructor: (@position, @name, @icon) ->
      @marker

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

  class player extends location
    constructor: (@position, @name, @icon) ->
      super(@position, @name, @icon)
      @playerMarker

    initTo: (map) ->
      @playerMarker = new google.maps.Marker({
        position: @position,
        map: map,
        icon: @icon,
        title: 'Mark'
      })
    
    moveTo: (location) ->
      console.log("current position", this.position, "new position", location.position, "distance travelled", distanceTravelled(this.position, location.position) + 'km')
      @position = location.position
      @playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng))

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
          processedData.push(item['dcterms:spatial'].split(';'))
    return processedData

  generateMarkers = (set) ->
    marker = []
    i = 0
    for place in set
      lat = parseFloat(place[1].split(',')[0])
      lng = parseFloat(place[1].split(',')[1])
      marker[i] = new location {lat, lng}, place[0]
      marker[i].addTo(googleMap)
      i++
    return

  googleMap = new google.maps.Map($('#map')[0], {
    zoom: 6,
    center: {lat:-27.4698, lng: 153.0251}
  })

  mark = new player {lat: -25.363, lng: 151.044}, 'Mark', 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  mark.initTo(googleMap)
  #brisbane = new location {lat:-27.4698, lng: 153.0251}, 'brisbane'
  #brisbane.addTo(@map)

  retrieveResources(100).then (res) ->
    generateMarkers(processData(res))
    return

  return
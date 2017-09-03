jQuery(document).ready ->
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
  googleMap = new google.maps.Map($('#map')[0], {
    zoom: 6,
    center: {lat:-27.4698, lng: 153.0251}
  })

  mark = new player {lat: -25.363, lng: 151.044}, 'Mark', 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png'
  mark.initTo(googleMap)
  #brisbane = new location {lat:-27.4698, lng: 153.0251}, 'brisbane'
  #brisbane.addTo(@map)

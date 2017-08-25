jQuery(document).ready ->

  class puzzleGame
    constructor: (@debug, @xsplit, @ysplit, @answers) ->

    init: (@resources) ->
      primImg = $('#defaultImg')
      $(primImg).css 'background-image', 'url(' + @resources[0]['High resolution image'] + ')'
      tiles = @xsplit * @ysplit
      imgWidth = primImg.width()
      imgHeight = primImg.height()
      tileWidth = imgWidth/@xsplit
      tileHeight = imgHeight/@ysplit
      i = 0
      col = 0
      while col < @ysplit
        row = 0
        while row < @xsplit
          tile = $(primImg.clone())
          tile.draggable()
          tile.addClass 'tile'
          tile.removeAttr 'id', ''
          tile.css {
            'background-image': primImg.css 'background-image'
            'background-position': -row*tileWidth+'px ' + -col*tileHeight+'px',
            'width': tileWidth,
            'height': tileHeight
          }
          tile
          $('#gameArea').append(tile)
          i++
          row++
          if @debug
            console.log('created', i, 'tile at', row, col)
        col++
      primImg.hide()
      if @debug
        console.log('current selector', primImg, '--- Width', imgWidth, 'Height', imgHeight, 'TileWidth', tileWidth, 'TileHight',tileHeight)
        console.log('solution', @resources[0])
    reset: ->
      console.log(@resources)
      console.log('abstract reset method')

  currentGame = new puzzleGame true, 4, 4, 8

  reqParam = {
    resource_id: 'cf6e12d8-bd8d-4232-9843-7fa3195cee1c',
    limit: 10
  };

  retrieveResources = ->
    $.ajax {
      url: 'http://data.gov.au/api/action/datastore_search',
      data: reqParam,
      dataType: 'jsonp',
      cache: true
    }

  processData = (data) ->
    processedData = []
    for item in data.result.records
      if item['High resolution image']
        processedData.push(item)
    return processedData

  $('#play').click ->
    retrieveResources().then (res) ->
      currentGame.init(processData(res))
      return
    return

  $('#reset').click ->
    currentGame.reset()
    return

  return
   

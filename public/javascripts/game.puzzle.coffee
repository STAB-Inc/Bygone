jQuery(document).ready ->

  class puzzleGame
    constructor: (@debug, @xsplit, @ysplit) ->

    init: (@resources) ->
      @reset()
      console.log(@resources)
      solution = @resources[Math.floor(Math.random() * @resources.length)]
      @generateChoiceField(@resources, solution)
      @generateTiles(solution)
    
    generateTiles: (solution) ->
      tileTemplate = $('#tileTemplate')
      tiles = @xsplit * @ysplit
      imgWidth = $('#tileTemplate').width()
      imgHeight = $('#tileTemplate').height()
      console.log()
      tileWidth = imgWidth/@xsplit
      tileHeight = imgHeight/@ysplit
      i = 0
      col = 0
      while col < @ysplit
        row = 0
        while row < @xsplit
          tile = $(tileTemplate.clone())
          tile.draggable()
          tile.show()
          tile.addClass 'tile'
          tile.removeAttr 'id', ''
          tile.css {
            'background-image': 'url(' + solution['High resolution image'] + ')',
            'background-position': -row*tileWidth+'px ' + -col*tileHeight+'px',
            'width': tileWidth,
            'height': tileHeight,
            'left': Math.floor(Math.random() * 400) + 'px',
            'top': Math.floor(Math.random() * 200) + 'px'
          }
          $('#gameArea').append(tile)
          i++
          row++
          if @debug
            console.log('created', i, 'tile at', row, col)
        col++
      tileTemplate.hide()
      if @debug
        console.log('--- Width', imgWidth, 'Height', imgHeight, 'TileWidth', tileWidth, 'TileHight',tileHeight)
        console.log('solution', @getAnswer())

    generateChoiceField: (choices, solution) ->
      i = 1
      for choice in choices
        if choice == solution 
          $('#selectionArea').append('<div class="choice" id="choice'+i+'"><img class="img-responsive" src="'+ choice['High resolution image']+'"</div>')
          @setAnswer(solution, i)
        else
          $('#selectionArea').append('<div class="choice" id="choice'+i+'"><img class="img-responsive" src="'+ choice['High resolution image']+'"</div>')
        i++

    setAnswer:(answer, value) ->
      @answer = answer
      @solutionValue = value

    getAnswer: ->
      return [@answer, @solutionValue]

    reset: ->
      $('#selectionArea, #gameArea').empty()
      console.log('abstract reset method')

  currentGame = new puzzleGame true, 4, 4



  retrieveResources = (amount) ->
    reqParam = {
      resource_id: 'cf6e12d8-bd8d-4232-9843-7fa3195cee1c',
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
      if item['High resolution image']
        processedData.push(item)
    return processedData

  $('#play').click ->
    retrieveResources(50).then (res) ->
      currentGame.init(processData(res))
      return
    return

  $('#selectionArea').on 'click', '.choice', ->
    console.log(parseInt($(this).attr('id').match(/[0-9]+/)), currentGame.getAnswer()[1])
    if parseInt($(this).attr('id').match(/[0-9]+/)) == currentGame.getAnswer()[1]
      console.log('correct')
    else
      console.log('wrong')
    return

  $('#reset').click ->
    currentGame.reset()
    return

  return
   

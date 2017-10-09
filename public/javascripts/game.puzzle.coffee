jQuery(document).ready ->

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data
      
  getParam = (name) ->
    results = new RegExp('[\?&]' + name + '=([^&#]*)').exec window.location.href
    return results[1] || 0

  class puzzleGame
    constructor: (@debug, @xsplit, @ysplit, @amount) ->
      @timePassed

    init: (@resources) ->
      @resources.sort ->
        return 0.5 - Math.random()
      resourceLimit = @resources.slice(0, @amount)
      @solution = resourceLimit[Math.floor(Math.random() * resourceLimit.length)]
      console.log @solution
      @reset()
      @generateChoiceField(resourceLimit)
      @generateTiles()
      @initTimer()

    initTimer: () ->
      time = 0
      counter = ->
        time += 1
        $('#timer').text 'Time: ' + time
        $('#timer').attr 'value', time
      @timer = setInterval(counter, 1000)

    generateTiles: ->
      tileTemplate = $('#tileTemplate')
      tiles = @xsplit * @ysplit
      imgWidth = $('#tileTemplate').width()
      imgHeight = $('#tileTemplate').height()
      tileWidth = imgWidth/@xsplit
      tileHeight = imgHeight/@ysplit
      i = 0
      col = 0
      while col < @ysplit
        row = 0
        while row < @xsplit
          tile = $(tileTemplate.clone())
          tile.draggable({
            containment:$('#gameArea'),
            snap: true,
            snapMode: "both"
            })
          tile.show()
          tile.addClass 'tile'
          tile.removeAttr 'id', ''
          tile.css {
            'background-image': 'url(' + @solution['High resolution image'] + ')',
            'background-position': -row*tileWidth+'px ' + -col*tileHeight+'px',
            'width': tileWidth,
            'height': tileHeight,
            'left': Math.floor(Math.random() * 100) + 'px',
            'top': Math.floor(Math.random() * 100) + 'px'
          }
          $('#gameArea').append(tile)
          i++
          row++
          if @debug
            console.log('created', i, 'tile at', row-1, col)
        col++
      tileTemplate.hide()
      if @debug
        console.log('--- Width', imgWidth, 'Height', imgHeight, 'TileWidth', tileWidth, 'TileHight',tileHeight)
        console.log('solution', @getAnswer())

    generateChoiceField: (choices) ->
      i = 1
      for choice in choices
        if choice == @solution 
          $('#selectionArea').append('<div class="choice" id="choice'+i+'"><img class="img-responsive" src="'+ choice['Thumbnail image']+'"</div>')
          @setAnswerValue(i)
        else
          $('#selectionArea').append('<div class="choice" id="choice'+i+'"><img class="img-responsive" src="'+ choice['Thumbnail image']+'"</div>')
        i++

    setAnswerValue:(value) ->
      @solutionValue = value

    getAnswer: ->
      return [@solution, @solutionValue]

    reset: ->
      $('#selectionArea, #gameArea').empty()
      clearInterval(@timer);
      @time = 0;

    gameWin: ->
      $('.winScreen .timeTaken').text 'Time taken : ' + $('#timer').attr('value') + ' seconds'
      $('.winScreen').show()
      $('.winScreen img').attr 'src', @solution['High resolution image']
      $('.winScreen .soldierName').text @solution['Full name (from National Archives of Australia)']
      $('.winScreen .soldierDesc').text @solution['Title of image']
      $('.play').show()
      @reset()

    gameLose: ->
      alert('Wrong Answer')
      $('.play').show()

  retrieveResources = (amount) ->
    reqParam = {
      resource_id: 'cf6e12d8-bd8d-4232-9843-7fa3195cee1c',
      limit: amount
    }
    $.ajax {
      url: 'https://data.gov.au/api/action/datastore_search',
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
    
  load = ->
    $('#loader').css {
      'opacity': 0,
      'pointer-events': 'none',
    }
    $('body').css 'overflow-y', 'auto'
    setTimeout ->
      $('#loader').css {
        'display': 'none',
        'left': -1*$('#loader').width()
        }
    , 1000

  try
    storyMode = getParam('story') == 'true'
    if storyMode
      $('#playAgain').text 'Continue'
      $('#playAgain').parent().attr 'href', 'chapter2.html'
      $('.skip').show()
      $('.save').hide()
      $('#playAgain').addClass('continue')
    switch getParam('diff')
      when "easy" then currentGame = new puzzleGame false, 4, 4, 20
      when "normal" then currentGame = new puzzleGame false, 8, 8, 30
      when "hard" then currentGame = new puzzleGame false, 12, 12, 50
      else currentGame = new puzzleGame false, 4, 4, 20
  
    retrieveResources(1000).then (res) ->
      load()
      currentGame.init processData(res)

  $('.skip, .continue').click (e) ->
    $('.continueScreen').show();
    $('#selectionArea, #gameArea').hide();
    submitUserData({
      method: 'chapterComplete'
      chapterId: '1'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        return

  # $('.save').click ->
  #   submitUserData({
  #     method: 'saveScore'
  #   }).then (res) ->
  #     res = JSON.parse res
  #     if res.status == 'success'
  #       location.reload()

  $('.winScreen').hide();

  $('#selectionArea').on 'click', '.choice', ->
    if parseInt($(this).attr('id').match(/[0-9]+/)) == currentGame.getAnswer()[1]
      currentGame.gameWin()
    else
      currentGame.gameLose()
    return

  $('#playAgain').click ->
    #location.reload()

  $('#reset').click ->
    currentGame.reset()
    return

  return
   

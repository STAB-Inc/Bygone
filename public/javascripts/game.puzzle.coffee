###
@file
Handles the functionality of the puzzle game.
###

jQuery(document).ready ->

  ###
    Submits session data to the server. 
    @param {object} data - the data to be submitted.
    @return AJAX deferred promise.
  ###

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data
  
  ###
    Gets the value of the paramater in the query string of a GET request.
    @param {string} name - the key of the corrosponding value to retrieve.
    @return The sorted array.
  ###

  getParam = (name) ->
    results = new RegExp('[\?&]' + name + '=([^&#]*)').exec window.location.href
    return results[1] || 0

  class puzzleGame
    ###
      Constructs the puzzle game object.
      @constructor
      @param {boolean} debug
        The debug state of the game.

      @param {integer} xsplit.
        The segments to slice the game grid horizontally.

      @param {integer} ysplit.
        The segments to slice the game grid vertically.

      @param {integer} amount.
        The amount of choices to generate.
    ###
    constructor: (@debug, @xsplit, @ysplit, @amount) ->
      @attempts = 0

    ###
      Initialize the game.

      @param {array} resources
        The array of resources for the game to generate from.
    ###

    init: (@resources) ->
      @resources.sort ->
        return 0.5 - Math.random()
      resourceLimit = @resources.slice(0, @amount)
      @solution = resourceLimit[Math.floor(Math.random() * resourceLimit.length)]
      @reset()
      @generateChoiceField(resourceLimit)
      @generateTiles()
      @initTimer()

    ###
      Initialize the timer.
    ###

    initTimer: () ->
      time = 0
      counter = ->
        time += 1
        $('#timer').text 'Time: ' + time
        $('#timer').attr 'value', time
      @timer = setInterval(counter, 1000)

    ###
      Generates the puzzle tiles.
    ###

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

    ###
      Generates the avaliable choices for the user.
      @param {array} choices
        The set of choices to generate from.
    ###

    generateChoiceField: (choices) ->
      i = 1
      for choice in choices
        if choice == @solution 
          $('#selectionArea').append('<div class="choice" id="choice'+i+'"><img class="img-responsive" src="'+ choice['Thumbnail image']+'"</div>')
          @setAnswerValue(i)
        else
          $('#selectionArea').append('<div class="choice" id="choice'+i+'"><img class="img-responsive" src="'+ choice['Thumbnail image']+'"</div>')
        i++

    ###
      Sets the index value of the solution.
    ###

    setAnswerValue:(value) ->
      @solutionValue = value

    ###
      Gets the current answer
      @return
        The array of the solution and its corrosponding index.
    ###

    getAnswer: ->
      return [@solution, @solutionValue]

    ###
      Resets the game.
    ###

    reset: ->
      $('#selectionArea, #gameArea').empty()
      clearInterval(@timer);
      @time = 0;

    ###
      Display the game win screen.
    ###

    gameWin: ->
      @score = (300*@amount) - parseInt($('#timer').attr('value')) - (1000*@attempts)
      $('.winScreen .timeTaken').text 'Time taken : ' + $('#timer').attr('value') + ' seconds'
      $('.winScreen .finalScore').text 'Your score : ' + @score + ' pts'
      $('.winScreen').show()
      $('.winScreen img').attr 'src', @solution['High resolution image']
      $('.winScreen .soldierName').text @solution['Full name (from National Archives of Australia)']
      $('.winScreen .soldierDesc').text @solution['Title of image']
      $('.play').show()
      @reset()

    ###
      Increment the attempts each time a incorrect choice is made.
    ###

    gameLose: ->
      @attempts += 1
      $('#attempts').text 'Attempts: ' + @attempts

    ###
      Saves the current user score.
    ###

    saveScore: ->
      submitUserData({
        method: 'saveScore'
        gameId: '1'
        value: @score
      }).then (res) ->
        res = JSON.parse res
        if res.status == 'success'
          $('.winScreen .status').text res.message

    ###
      Saves the a item to the user's collection.
    ###

    saveItem: ->
      submitUserData({
        method: 'saveItem'
        image: @solution['High resolution image']
        description: @solution['Title of image']
      }).then (res) ->
        res = JSON.parse res
        if res.status == 'success'
          $('.winScreen .status').text res.message

  ###
    Retrieves resources from the dataset.
    @param {integer} amount
      The amount of resources to retrieve.

    @return
      AJAX deferred promise.
  ###

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

  ###
    Processes and validates an array of data.
    @param {array} data
      The set of data to process.

    @return
      The array of processed data.
  ###

  processData = (data) ->
    processedData = []
    for item in data.result.records
      if item['High resolution image']
        processedData.push(item)
    return processedData
    
  ###
    Loads the page by removing the loading screen.
  ###

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

  ###
    Retrieves the GET paramater from the query string. Sets up the interface and constructs the Puzzle game object accordingly.
  ###

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

    ###
      Initialize the game.
      @see retrieveResources()
      @see processData()
      @see puzzleGame.prototype.init()
    ###
  
    retrieveResources(1000).then (res) ->
      load()
      currentGame.init processData(res)

  ###
    Skips the game when in story mode. Completes the chapter for the user.
  ###

  $('.skip, .continue').click (e) ->
    $('.continueScreen').show()
    $('#selectionArea, #gameArea').hide()
    submitUserData({
      method: 'chapterComplete'
      chapterId: '1'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        return
    
  ###
    Saves the current score.
  ###

  $('#saveScore').click ->
    currentGame.saveScore()

  ###
    Saves the item to the user's collection.
  ###

  $('#saveItem').click ->
    currentGame.saveItem()

  ###
    Disables the save button.
  ###

  $('.save').click ->
    $(this).prop 'disabled', true

  $('.winScreen').hide();

  ###
    Binds click event to choices generated after the DOM has been loaded.
  ###

  $('#selectionArea').on 'click', '.choice', ->
    if parseInt($(this).attr('id').match(/[0-9]+/)) == currentGame.getAnswer()[1]
      currentGame.gameWin()
    else
      currentGame.gameLose()
    return

  ###
    Refreshes the page.
  ###

  $('#playAgain').click ->
    location.reload()
  
  ###
    Resets the game.
  ###

  $('#reset').click ->
    currentGame.reset()

  return
   

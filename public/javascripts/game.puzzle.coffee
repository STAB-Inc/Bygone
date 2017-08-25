class puzzleGame
  constructor: (@debug) ->
  init: ->
    if @debug
      console.log('debug enabled')

jQuery(document).ready ->
  $('#test').click ->
    xsplit = 4
    ysplit = 4
    tiles = xsplit * ysplit
    imgWidth = $('#defaultImg').width()
    imgHeight = $('#defaultImg').height()
    tileWidth = imgWidth/xsplit
    tileHeight = imgHeight/ysplit
    console.log(imgWidth, imgHeight, tileWidth, tileHeight)
    i = 0
    col = 0
    while col < ysplit
      row = 0
      while row < xsplit
        tile = $('#defaultImg').clone()
        $(tile).draggable()
        pos = $('#defaultImg').position()
        $(tile).css {
            'background-position': -row*tileWidth+'px ' + -col*tileHeight+'px',
            'width': tileWidth,
            'height': tileHeight
          }
        $('main').append(tile)
        i++
        row++
        console.log('created', i, 'tile', i*tileWidth+'px ' + i*tileHeight+'px', row, col)
      col++
    $('#defaultImg').hide()
    currentGame = new puzzleGame 'true'
    currentGame.init()
    return
  return
   

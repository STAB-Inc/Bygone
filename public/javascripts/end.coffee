jQuery(document).ready ->
  $('p').hide()

  $('body').click ->
    next()

  i = 0
  init = 0
  next = ->
    p = $('main p')
    $(p[i]).fadeIn()
    i++
    if $(p[i]).hasClass 'trig'
      init = i + 2
      $('body').css 'background-color', '#000000'
    if i == init
      $('main p').fadeOut 1000, ->
        $('main img').css 'opacity', '1';
        $('main img').css 'transform', 'scale(1)';
        setTimeout ->
          window.location = '../index.html'
        , 3000
      
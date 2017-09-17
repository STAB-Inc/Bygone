$(document).ready ->

  navToggle = ->
    navToggled = !navToggled
    $('nav#global').toggleClass 'navOn'
    $('.ionClose, .ionOpen').toggleClass 'buttonActive'

  navToggled = false

  $('#navToggle, .navContainer').click ->
    navToggle()

  toHash = (hash) ->
    $('body').animate({
      'scrollTop': $(hash).offset().top
    }, 750)
    return

  toLink= (link) ->

  $('a').click (e) ->
    e.preventDefault()
    href = $(this).attr 'href'
    if href.charAt(0) == '#'
      toHash href
    else
      $('#loader').show()
      $('#loader').css 'opacity', 1
      $('#loader').empty()
      $('#loader').animate({
        'left': '0px'
      }, 50, ->
        setTimeout ->
          window.location = href
        , 1000
      )

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

  #loader delayed for testing

  imagesTotal = $('img').length
  segment = 100 / imagesTotal
  loaded = 0
  $(document).imagesLoaded().progress((instance, image) ->
    animateText = (from, to) ->
    if image.isLoaded
      loaded += segment
      setTimeout ->
        $('#loader .loaderBar').css 'width', loaded + '%'
      , 1500
    else
      $('.failed').append '<p>Fail to load: ' + image.img.src + '</p>'
    return
  ).done ->
    setTimeout ->
      load()
    , 2000
    return

  $('.close').click ->
    $(this).parent().hide()
    return

  return
# ---
# generated by js2coffee 2.2.0
$(document).ready ->

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data

  submitUserData({
      method: 'getActiveUser'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        $('.formContainer').hide()
        submitUserData({
          method: 'getUserData'
          id: res.message
        }).then (userData) ->
          userData = JSON.parse userData
          $('#activeUserMsg').show()
          $('#activeUserMsg p').text 'Welcome ' + userData.username
          for key in Object.keys userData.unlockables
            if userData.unlockables[key]
              $('#' + key).removeClass 'locked'
              $('#g' + key).find('.locked').hide()
              $('#' + key).find('.stateContainer').css 'opacity', 0
          amt = 0
          for item in userData.collections
            amt += 1
            $('.userProfile .collections').append( 
              $('<div class="collection">
                  <img src="' + item[1] + '">
                  <p>' + item[0] + '</p>
                </div>'
              )
            )
          $('.colAmt').text amt + ' Item/s'
      else
        $('.save').hide()

  $('#newUser').submit (e) ->
    e.preventDefault()
    if $('#newUser #password').val() != $('#newUser #cPassword').val()
      $('#newUser').find('.error').text 'Password do not match.'
      return 0
    if $('#newUser #password').val() == '' || $('#newUser #cPassword').val() == '' || $('#newUser #username').val()  == ''
      $('#newUser').find('.error').text 'Field cannot be empty'
      return 0
    submitUserData({
      method: 'new'
      username: $('form#newUser #username').val()
      password:  $('form#newUser #password').val()
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'error'
        $('#newUser').find('.error').text res.message
      else
        location.reload()
  
  $('#loginUser').submit (e) ->
    e.preventDefault()
    submitUserData({
      method: 'login'
      username: $('form#loginUser #username').val()
      password:  $('form#loginUser #password').val()
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'error'
        $('#loginUser').find('.error').text res.message
      else
        location.reload()
    
  navToggle = ->
    navToggled = !navToggled
    $('nav#global').toggleClass 'navOn'
    $('.ionClose, .ionOpen').toggleClass 'buttonActive'

  navToggled = false

  userLogToggle = ->
    userToggled = !userToggled
    if userToggled then $('.userProfile').fadeIn()

  userToggled = false

  $('#navToggle, .navContainer').click ->
    navToggle()

  $('.viewProf').click ->
    userLogToggle()

  $('#activeUserMsg').click ->
    $('#userActions').toggleClass('showActions')

  toHash = (hash) ->
    $('body').animate({
      'scrollTop': $(hash).offset().top
    }, 750)
    return

  toLink= (link) ->

  $('a').click (e) ->
    e.preventDefault()
    if $(this).find('.chapter').hasClass 'locked'
      $(this).find('.stateContainer i').animate {
        color: 'red'
      }, 500, ->
        $(this).animate {
          color: 'white'
        }, 500
      return 0;
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
    if window.location.pathname.split("/").pop() != 'game.Shooting.html'
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
    if image.isLoaded
      loaded += segment
      setTimeout ->
        $('#loader .loaderBar').css 'width', loaded + '%'
      , 100
    else
      $('.failed').append '<p>Fail to load: ' + image.img.src + '</p>'
    return
  ).done ->
    setTimeout ->
      load()
    , 500
    return

  $('.close, .closeForm').click ->
    $(this).parent().fadeOut()

  $('.show').click ->
    $($(this).attr('target')).fadeIn()

  $('button').click (e) ->
    e.preventDefault()

  $('#userActions .logout').click ->
    submitUserData({
      method: 'logout'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        location.reload()

  $('#userActions .deleteAcc').click ->
    submitUserData({
      method: 'deleteUser'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        location.reload()
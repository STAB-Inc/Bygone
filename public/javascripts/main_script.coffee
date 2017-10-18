$(document).ready ->

  ###
    Submits session data to the server. 
    @param {Object} data - the data to be submitted.
  ###

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data

  ###
    Gets the active user.
  ###

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

  ###
    Creates a new user.
  ###

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

  ###
    Logs users in.
  ###
  
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

  ###
    Toggles the navigation.
  ###
    
  navToggle = ->
    navToggled = !navToggled
    $('nav#global').toggleClass 'navOn'
    $('.ionClose, .ionOpen').toggleClass 'buttonActive'

  ###
    Initial navigation menu status.
  ###
  navToggled = false

  ###
    Toggles user profile.
  ###
  userLogToggle = ->
    userToggled = !userToggled
    if userToggled then $('.userProfile').fadeIn()

  userToggled = false

  ###
    Shows/Hides the navigation.
  ###

  $('#navToggle, .navContainer').click ->
    navToggle()

  ###
    Shows/Hides the user profile.
  ###

  $('.viewProf').click ->
    userLogToggle()

  ###
    Toggles user actions.
  ###

  $('#activeUserMsg').click ->
    $('#userActions').toggleClass('showActions')

  ###
    Scrolls the user to a section.
    @param {string} hash - the element with the hash to scroll to.
  ###

  toHash = (hash) ->
    $('body').animate({
      'scrollTop': $(hash).offset().top
    }, 750)
    return

  ###
    Page transitions.
  ###

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

  ###
    Loads the page by removing the loading screen.
  ###

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

  ###
    Images loaded plugin, waits for all images to load and fires a event once complete.
  ###

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

  ###
    Hides overlays.
  ###

  $('.close, .closeForm').click ->
  ###
    @file
    Tge global scripts for BYGONE.
  ###

    $(this).parent().fadeOut()

  ###
    Show overlays.
  ###

  $('.show').click ->
    $($(this).attr('target')).fadeIn()

  ###
    Stops button redirects.
  ###

  $('button').click (e) ->
    e.preventDefault()

  ###
    Log out the current user.
  ###

  $('#userActions .logout').click ->
    submitUserData({
      method: 'logout'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        location.reload()

  ###
    Deletes the user's account.
  ###

  $('#userActions .deleteAcc').click ->
    submitUserData({
      method: 'deleteUser'
    }).then (res) ->
      res = JSON.parse res
      if res.status == 'success'
        location.reload()
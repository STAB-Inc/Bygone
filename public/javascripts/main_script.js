// Generated by CoffeeScript 1.12.7
(function() {
  $(document).ready(function() {
    var imagesTotal, load, loaded, navToggle, navToggled, segment, submitUserData, toHash, toLink, userLogToggle, userToggled;
    submitUserData = function(data) {
      return $.ajax({
        url: '/routes/user.php',
        type: 'POST',
        data: data
      });
    };
    submitUserData({
      method: 'getActiveUser'
    }).then(function(res) {
      res = JSON.parse(res);
      if (res.status === 'success') {
        $('.formContainer').hide();
        return submitUserData({
          method: 'getUserData',
          id: res.message
        }).then(function(userData) {
          var i, key, len, ref, results;
          userData = JSON.parse(userData);
          $('#activeUserMsg').show();
          $('#activeUserMsg p').text('Welcome ' + userData.username);
          ref = Object.keys(userData.unlockables);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            key = ref[i];
            if (userData.unlockables[key]) {
              $('#' + key).removeClass('locked');
              $('#g' + key).find('.locked').hide();
              results.push($('#' + key).find('.stateContainer').css('opacity', 0));
            } else {
              results.push(void 0);
            }
          }
          return results;
        });
      }
    });
    $('#newUser').submit(function(e) {
      e.preventDefault();
      if ($('#newUser #password').val() !== $('#newUser #cPassword').val()) {
        $('#newUser').find('.error').text('Password do not match.');
        return 0;
      }
      if ($('#newUser #password').val() === '' || $('#newUser #cPassword').val() === '' || $('#newUser #username').val() === '') {
        $('#newUser').find('.error').text('Field cannot be empty');
        return 0;
      }
      return submitUserData({
        method: 'new',
        username: $('form#newUser #username').val(),
        password: $('form#newUser #password').val()
      }).then(function(res) {
        res = JSON.parse(res);
        if (res.status === 'error') {
          return $('#newUser').find('.error').text(res.message);
        } else {
          return location.reload();
        }
      });
    });
    $('#loginUser').submit(function(e) {
      e.preventDefault();
      return submitUserData({
        method: 'login',
        username: $('form#loginUser #username').val(),
        password: $('form#loginUser #password').val()
      }).then(function(res) {
        res = JSON.parse(res);
        if (res.status === 'error') {
          return $('#loginUser').find('.error').text(res.message);
        } else {
          return location.reload();
        }
      });
    });
    navToggle = function() {
      var navToggled;
      navToggled = !navToggled;
      $('nav#global').toggleClass('navOn');
      return $('.ionClose, .ionOpen').toggleClass('buttonActive');
    };
    navToggled = false;
    userLogToggle = function() {
      var userToggled;
      userToggled = !userToggled;
      if (userToggled) {
        return $('.userProfile').fadeIn();
      }
    };
    userToggled = false;
    $('#navToggle, .navContainer').click(function() {
      return navToggle();
    });
    $('.viewProf').click(function() {
      return userLogToggle();
    });
    $('#activeUserMsg').click(function() {
      return $('#userActions').toggleClass('showActions');
    });
    toHash = function(hash) {
      $('body').animate({
        'scrollTop': $(hash).offset().top
      }, 750);
    };
    toLink = function(link) {};
    $('a').click(function(e) {
      var href;
      e.preventDefault();
      if ($(this).find('.chapter').hasClass('locked')) {
        $(this).find('.stateContainer i').animate({
          color: 'red'
        }, 500, function() {
          return $(this).animate({
            color: 'white'
          }, 500);
        });
        return 0;
      }
      href = $(this).attr('href');
      if (href.charAt(0) === '#') {
        return toHash(href);
      } else {
        $('#loader').show();
        $('#loader').css('opacity', 1);
        $('#loader').empty();
        return $('#loader').animate({
          'left': '0px'
        }, 50, function() {
          return setTimeout(function() {
            return window.location = href;
          }, 1000);
        });
      }
    });
    load = function() {
      $('#loader').css({
        'opacity': 0,
        'pointer-events': 'none'
      });
      if (window.location.pathname.split("/").pop() !== 'game.Shooting.html') {
        $('body').css('overflow-y', 'auto');
      }
      return setTimeout(function() {
        return $('#loader').css({
          'display': 'none',
          'left': -1 * $('#loader').width()
        });
      }, 1000);
    };
    imagesTotal = $('img').length;
    segment = 100 / imagesTotal;
    loaded = 0;
    $(document).imagesLoaded().progress(function(instance, image) {
      if (image.isLoaded) {
        loaded += segment;
        setTimeout(function() {
          return $('#loader .loaderBar').css('width', loaded + '%');
        }, 100);
      } else {
        $('.failed').append('<p>Fail to load: ' + image.img.src + '</p>');
      }
    }).done(function() {
      setTimeout(function() {
        return load();
      }, 500);
    });
    $('.close, .closeForm').click(function() {
      return $(this).parent().fadeOut();
    });
    $('.show').click(function() {
      return $($(this).attr('target')).fadeIn();
    });
    $('button').click(function(e) {
      return e.preventDefault();
    });
    $('#userActions .logout').click(function() {
      return submitUserData({
        method: 'logout'
      }).then(function(res) {
        res = JSON.parse(res);
        if (res.status === 'success') {
          return location.reload();
        }
      });
    });
    $('#userActions .deleteAcc').click(function() {
      return submitUserData({
        method: 'deleteUser'
      }).then(function(res) {
        res = JSON.parse(res);
        if (res.status === 'success') {
          return location.reload();
        }
      });
    });
  });

}).call(this);

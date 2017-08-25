$(document).ready( function () {
  'use strict';

  var toggleState;
  $('#index-nav .index').click( function (e) {
    e.preventDefault();
    if ($(this).hasClass('no-redirect')) {
      initButtonToggle(this);
    }
    else {
      console.log('redirect')
    }
  });

  function initButtonToggle(_this) {
    if (!toggleState) {
      $(_this).children().css('width', '100%');
      $(_this).css('width', '100%');
      $(_this).find('.bg').css({
        'width': '100%',
        'left': '0' 
      });
      $(_this).find('h5').css({
        'color': 'white',
      });
      $(_this).find('.chapter-selection').css({
        'margin-left': '0',
        'pointer-events': 'all'
      });
      $(_this).find('.chapter-selection a').css({
        'transform': 'rotate(0)',
        'opacity': 1,
        'margin': '0 10px 0 10px'
      });
    }
    else {
      //$(_this).children().css('width', '');
      $(_this).find('.bg').css({
        'width': '',
        'left': '' 
      });
      $(_this).find('h5').css({
        'color': '',
      });
      $(_this).find('.chapter-selection').css({
        'margin-left': '',
        'pointer-events': ''
      });
      $(_this).find('.chapter-selection a').css({
        'transform': '',
        'opacity': '',
        'margin': ''
      });
    }
    toggleState = !toggleState;
  }

});
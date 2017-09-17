// Generated by CoffeeScript 1.12.7
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  jQuery(document).ready(function() {
    var addShotToInv, calculatePicValue, closeParent, currentGame, deg2rad, displayInv, distanceTravelled, endGame, endTurn, event, eventManager, gameEvents, gameGlobal, gamePhoto, gameTime, generateMarkers, location, locations, mark, photographyGame, player, processData, retrieveResources, setValue, timeManager, updateMarkers;
    retrieveResources = function(amount) {
      var reqParam;
      reqParam = {
        resource_id: '9913b881-d76d-43f5-acd6-3541a130853d',
        limit: amount
      };
      return $.ajax({
        url: 'https://data.gov.au/api/action/datastore_search',
        data: reqParam,
        dataType: 'jsonp',
        cache: true
      });
    };
    locations = [];
    gameGlobal = {
      trackers: {
        monthPassed: 0,
        photosSold: 0,
        moneyEarned: 0
      },
      turnConsts: {
        interest: 1.5,
        pictureWashingTime: 14
      }
    };
    deg2rad = function(deg) {
      return deg * (Math.PI / 180);
    };
    distanceTravelled = function(from, to) {
      var R, a, c, dLat, dLng, dist, lat1, lat2, lng1, lng2;
      lat1 = from.lat;
      lng1 = from.lng;
      lat2 = to.lat;
      lng2 = to.lng;
      R = 6371;
      dLat = deg2rad(lat2 - lat1);
      dLng = deg2rad(lng2 - lng1);
      a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      dist = R * c;
      return dist;
    };
    location = (function() {
      function location(position, name, data1, rare1, icon) {
        this.position = position;
        this.name = name;
        this.data = data1;
        this.rare = rare1;
        this.icon = icon;
        this.marker;
        this.value;
        this.travelExpense;
        this.travelTime;
      }

      location.prototype.addTo = function(map) {
        var marker;
        if (this.icon) {
          marker = new google.maps.Marker({
            position: this.position,
            map: map,
            icon: this.icon,
            title: this.name
          });
        } else {
          marker = new google.maps.Marker({
            position: this.position,
            map: map,
            title: this.name
          });
        }
        this.marker = marker;
        return this.setListener(this.marker);
      };

      location.prototype.setListener = function(marker) {
        var self;
        self = this;
        marker.addListener('click', function() {
          return mark.moveTo(self);
        });
        return marker.addListener('mouseover', function() {
          var travelDistance, travelTime;
          travelDistance = parseInt(distanceTravelled(mark.position, self.position));
          travelTime = travelDistance / 232;
          $('#locationInfoOverlay #title').text(self.data.description);
          $('#locationInfoOverlay #position').text('Distance away ' + travelDistance + 'km');
          $('#locationInfoOverlay #value').text('Potential Revenue $' + self.value);
          $('#locationInfoOverlay #travelExpense').text('Travel Expense $' + parseInt((travelDistance * 0.6) / 10));
          $('#locationInfoOverlay #travelTime').text('Travel Time: at least ' + travelTime.toFixed(2) + ' Hours');
          return this.value = self.value;
        });
      };

      return location;

    })();
    player = (function(superClass) {
      extend(player, superClass);

      function player(position, name, data1, icon, stats1) {
        this.position = position;
        this.name = name;
        this.data = data1;
        this.icon = icon;
        this.stats = stats1;
        player.__super__.constructor.call(this, this.position, this.name, this.data, this.icon);
        this.playerMarker;
        this.inventory = [];
      }

      player.prototype.initTo = function(map) {
        return this.playerMarker = new google.maps.Marker({
          position: this.position,
          map: map,
          icon: 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png',
          title: this.name,
          optimized: false,
          zIndex: 100
        });
      };

      player.prototype.moveTo = function(location) {
        var newStats, timeTaken;
        location.travelExpense = parseInt((distanceTravelled(this.position, location.position) * 0.6) / 10);
        location.travelTime = parseFloat((distanceTravelled(this.position, location.position) / 232).toFixed(2));
        this.position = location.position;
        this.playerAt = location;
        this.playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng));
        newStats = this.stats;
        newStats.CAB -= mark.playerAt.travelExpense;
        timeTaken = location.travelTime + Math.random() * 5;
        gameTime.incrementTime(timeTaken);
        gameEvents.addEvent(new event('Moved to', gameTime.getFormatted(), location.name + ' in ' + timeTaken.toFixed(2) + ' hours'));
        $('#takePic').show();
        updateMarkers();
        return this.updateStats(newStats);
      };

      player.prototype.updateStats = function(stats) {
        var assets, workingCapital;
        this.stats = stats;
        assets = parseInt(this.stats.assets + this.stats.CAB);
        workingCapital = parseInt(assets - this.stats.liabilities);
        $('#playerInfoOverlay #stats #CAB').text('Cash at Bank $' + parseInt(this.stats.CAB));
        $('#playerInfoOverlay #stats #liabilities').text('Current Liabilities $' + parseInt(this.stats.liabilities));
        $('#playerInfoOverlay #stats #assets').text('Current Assets $' + assets);
        $('#playerInfoOverlay #stats #workingCapital').text('Working Capital $' + workingCapital);
        if (workingCapital <= -1000 && this.stats.CAB <= 0) {
          return endGame();
        }
      };

      return player;

    })(location);
    timeManager = (function() {
      function timeManager(baseTime) {
        this.baseTime = baseTime;
        this.timeCounter = 0;
        this.dateCounter = 0;
        this.monthCounter = 0;
        this.yearCounter = 0;
      }

      timeManager.prototype.incrementTime = function(hours) {
        var results;
        this.timeCounter += hours;
        results = [];
        while (this.timeCounter >= 24) {
          this.incrementDays(1);
          this.timeCounter -= 24;
          if (this.timeCounter < 24) {
            this.timeCounter = this.timeCounter % 24;
            break;
          } else {
            results.push(void 0);
          }
        }
        return results;
      };

      timeManager.prototype.incrementDays = function(days) {
        var results;
        this.dateCounter += days;
        results = [];
        while (this.dateCounter >= 30) {
          this.incrementMonths(1);
          this.dateCounter -= 30;
          endTurn(this.getFormatted());
          if (this.dateCounter < 30) {
            this.dateCounter = this.dateCounter % 30;
            break;
          } else {
            results.push(void 0);
          }
        }
        return results;
      };

      timeManager.prototype.incrementMonths = function(months) {
        var results;
        this.monthCounter += months;
        results = [];
        while (this.monthCounter >= 12) {
          this.incrementYears(1);
          this.monthCounter -= 12;
          if (this.monthCounter < 12) {
            this.monthCounter = this.monthCounter % 12;
            break;
          } else {
            results.push(void 0);
          }
        }
        return results;
      };

      timeManager.prototype.incrementYears = function(years) {
        return this.yearCounter += years;
      };

      timeManager.prototype.getAll = function() {
        return [this.baseTime[0] + this.yearCounter, this.baseTime[1] + this.monthCounter, this.baseTime[2] + this.dateCounter, parseInt(this.baseTime[3]) + this.timeCounter];
      };

      timeManager.prototype.getFormatted = function() {
        var date, hours, minutes, month, year;
        year = this.baseTime[0] + this.yearCounter;
        month = this.baseTime[1] + this.monthCounter;
        date = this.baseTime[2] + this.dateCounter;
        hours = parseInt(this.baseTime[3]) + this.timeCounter;
        minutes = parseInt((hours - Math.floor(hours)) * 60);
        if (date > 30) {
          date -= date - 30;
        }
        if (String(parseInt(minutes)).length === 2) {
          return year + '/' + month + '/' + date + ' ' + String(Math.floor(hours)) + ':' + String(parseInt(minutes));
        } else {
          return year + '/' + month + '/' + date + ' ' + String(Math.floor(hours)) + ':' + String(parseInt(minutes)) + '0';
        }
      };

      return timeManager;

    })();
    eventManager = (function() {
      function eventManager(domSelector) {
        this.domSelector = domSelector;
        this.events = [];
      }

      eventManager.prototype.addEvent = function(event) {
        this.events.push(event);
        if (event.special) {
          return $('<div class="row"> <p class="time special">' + event.time + '</p> <p class="title special">' + event.title + '</p> <p class="content special">' + event.content + '</p> </div>').prependTo(this.domSelector);
        } else {
          return $('<div class="row"> <p class="time">' + event.time + '</p> <p class="title">' + event.title + '</p> <p class="content">' + event.content + '</p> </div>').prependTo(this.domSelector);
        }
      };

      return eventManager;

    })();
    event = (function() {
      function event(title, time, content, special) {
        this.title = title;
        this.time = time;
        this.content = content;
        this.special = special != null ? special : false;
      }

      return event;

    })();
    gamePhoto = (function() {
      function gamePhoto(value, washed, img, title, quailty1) {
        this.value = value;
        this.washed = washed;
        this.img = img;
        this.title = title;
        this.quailty = quailty1;
      }

      return gamePhoto;

    })();
    processData = function(data) {
      var item, j, len, processedData, ref;
      processedData = [];
      ref = data.result.records;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (item['dcterms:spatial']) {
          if (item['dcterms:spatial'].split(';')[1]) {
            processedData.push(item);
          }
        }
      }
      return processedData;
    };
    generateMarkers = function(data) {
      var i, j, lat, len, lng, marker, place;
      marker = [];
      i = 0;
      for (j = 0, len = data.length; j < len; j++) {
        place = data[j];
        lat = parseFloat(place['dcterms:spatial'].split(';')[1].split(',')[0]);
        lng = parseFloat(place['dcterms:spatial'].split(';')[1].split(',')[1]);
        marker[i] = new location({
          lat: lat,
          lng: lng
        }, place['dcterms:spatial'].split(';')[0], {
          'title': place['dc:title'],
          'description': place['dc:description'],
          'img': place['150_pixel_jpg']
        }, false);
        marker[i].addTo(googleMap);
        locations.push(marker[i]);
        setValue(marker[i]);
        i++;
      }
      updateMarkers();
    };
    setValue = function(location) {
      var rare;
      rare = Math.random() <= 0.1;
      if (rare) {
        location.value = parseInt(Math.random() * distanceTravelled(mark.position, location.position) + 100);
        return location.rare = true;
      } else {
        return location.value = parseInt((Math.random() * distanceTravelled(mark.position, location.position) + 100) / 10);
      }
    };
    updateMarkers = function() {
      var hide, j, len, results, show;
      results = [];
      for (j = 0, len = locations.length; j < len; j++) {
        location = locations[j];
        hide = Math.random() >= 0.8;
        show = Math.random() <= 0.2;
        if (hide) {
          results.push(location.marker.setVisible(false));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    gameEvents = new eventManager($('#eventLog .eventContainer'));
    gameTime = new timeManager([1939, 1, 1, 0]);
    mark = new player({
      lat: -25.363,
      lng: 151.044
    }, 'Mark', {
      'type': 'self'
    }, 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png');
    mark.initTo(googleMap);
    mark.updateStats({
      'CAB': 1000,
      'workingCapital': 0,
      'assets': 0,
      'liabilities': 300
    });
    photographyGame = (function() {
      function photographyGame(debug) {
        this.debug = debug;
      }

      photographyGame.prototype.init = function(amount) {
        var localInit, validData;
        localInit = function() {
          validData.sort(function() {
            return 0.5 - Math.random();
          });
          generateMarkers(validData.slice(0, amount));
          return gameEvents.addEvent(new event('Game started', gameTime.getFormatted(), ''));
        };
        if (localStorage.getItem('photographyGameData')) {
          validData = processData(JSON.parse(localStorage.getItem('photographyGameData')));
          if (amount > validData.length) {
            return retrieveResources(1000).then(function(res) {
              localStorage.setItem('photographyGameData', JSON.stringify(res));
              validData = processData(res);
              return localInit();
            });
          } else {
            return localInit();
          }
        } else {
          return retrieveResources(1000).then(function(res) {
            localStorage.setItem('photographyGameData', JSON.stringify(res));
            validData = processData(res);
            return localInit();
          });
        }
      };

      return photographyGame;

    })();
    currentGame = new photographyGame(false);
    currentGame.init(100);
    endGame = function() {
      $('#gameEnd p').text('You survived for ' + gameGlobal.trackers.monthPassed + ' Months, selling ' + gameGlobal.trackers.photosSold + ' photos and making over $' + gameGlobal.trackers.moneyEarned);
      return $('#gameEnd').show();
    };
    endTurn = function(date) {
      var j, len, newStats, results, show;
      gameGlobal.trackers.monthPassed += 1;
      gameGlobal.turnConsts.interest = (Math.random() * 5).toFixed(2);
      newStats = mark.stats;
      newStats.CAB -= mark.stats.liabilities;
      mark.updateStats(newStats);
      gameEvents.addEvent(new event('The month comes to an end.', date, 'Paid $' + mark.stats.liabilities + ' in expenses', true));
      results = [];
      for (j = 0, len = locations.length; j < len; j++) {
        location = locations[j];
        show = Math.random() > 0.2;
        if (show) {
          results.push(location.marker.setVisible(true));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    $('#takePic').hide();
    $('#takePic').click(function() {
      $('#takingPic .section3').css('width', (Math.floor(Math.random() * (10 + 2))) + 1 + '%');
      $('#takingPic .section2').css('width', (Math.floor(Math.random() * (19 + 2))) + '%');
      $('#takingPic .section4').css('width', (Math.floor(Math.random() * (19 + 2))) + '%');
      $('#takingPic .slider').css('left', 0);
      $('#takingPic .start, #takingPic .stop').prop('disabled', false);
      $('#takingPic .shotStats').hide();
      $('#takingPic').show();
      $('#takingPic .viewInv').hide();
      $('#takingPic .close').hide();
      return $(this).hide();
    });
    addShotToInv = function(multiplier, quailty) {
      var newStats, photoValue, shotTaken;
      photoValue = mark.playerAt.value * multiplier;
      shotTaken = new gamePhoto(photoValue, false, mark.playerAt.data.img, mark.playerAt.data.title, quailty);
      mark.inventory.push(shotTaken);
      mark.playerAt.marker.setVisible(false);
      newStats = mark.stats;
      newStats.assets += photoValue;
      newStats.workingCapital -= mark.playerAt.travelExpense / 2;
      return mark.updateStats(newStats);
    };
    $('#takingPic .start').click(function() {
      $(this).prop('disabled', true);
      return $('#takingPic .slider').animate({
        'left': $('#takingPic .section1').width() + $('#takingPic .section2').width() + $('#takingPic .section3').width() + $('#takingPic .section4').width() + $('#takingPic .section5').width() + 'px'
      }, 1000, function() {
        return calculatePicValue();
      });
    });
    $('#takingPic .stop').click(function() {
      $(this).prop('disabled', true);
      $('#takingPic .slider').stop();
      $('#takingPic .close').show();
      return calculatePicValue();
    });
    calculatePicValue = function() {
      var inBlue, inGreen, multiplier, quailty, sliderPosition, timeTaken;
      $('#takingPic .viewInv').show();
      $('#takingPic .shotStats').show();
      multiplier = 1;
      quailty = 1;
      sliderPosition = parseInt($('#takingPic .slider').css('left'), 10);
      inBlue = ($('#takingPic .section1').position().left + $('#takingPic .section1').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section5').position().left;
      inGreen = ($('#takingPic .section2').position().left + $('#takingPic .section2').width()) <= sliderPosition && sliderPosition <= $('#takingPic .section4').position().left;
      if (inBlue && inGreen) {
        multiplier = 1.2;
        quailty = 0;
        $('.shotStats').text('You take a high quailty photo, this will surely sell for more!');
      } else if (inBlue) {
        $('.shotStats').text('You take a average photo.');
      } else {
        multiplier = 0.8;
        quailty = 2;
        $('.shotStats').text('The shot comes out all smudged...');
      }
      addShotToInv(multiplier, quailty);
      timeTaken = Math.floor(Math.random() * 10) + 24;
      gameTime.incrementTime(timeTaken);
      gameEvents.addEvent(new event('Taking Pictures', gameTime.getFormatted(), 'You spend some time around ' + mark.playerAt.name + '. ' + timeTaken + ' hours later, you finally take a picture of value.'));
      if (mark.playerAt.rare) {
        return gameEvents.addEvent(new event('Rare Picture.', gameTime.getFormatted(), 'You take a rare picture.', true));
      }
    };
    $('.viewInv').click(function() {
      closeParent(this);
      return displayInv();
    });
    $('#checkInv').click(function() {
      return displayInv();
    });
    displayInv = function() {
      var item, j, len, picture, pictureContainer, potentialValue, ref, sellableValue;
      $('#blockOverlay').show();
      $('#inventory .photoContainer').remove();
      $('#inventory').show();
      potentialValue = 0;
      sellableValue = 0;
      ref = mark.inventory;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        pictureContainer = $('<div class="photoContainer"></div>');
        picture = $('<div class="crop"> <img class="photo" src="' + item.img + '"/> </div>').css('filter', 'blur(' + item.quailty + 'px');
        picture.appendTo(pictureContainer);
        if (!item.washed) {
          pictureContainer.appendTo($('#inventory .cameraRoll'));
          potentialValue += item.value;
        } else {
          pictureContainer.appendTo($('#inventory .washedPics'));
          sellableValue += item.value;
        }
        $('<aside> <p>Value $' + parseInt(item.value) + '</p> <p>' + item.title + '</p> </aside>').appendTo(pictureContainer);
      }
      $('#rollValue').text('Total value $' + parseInt(potentialValue + sellableValue));
      return $('#sellableValue').text('Sellable Pictures value $' + parseInt(sellableValue));
    };
    $('#wait').click(function() {
      return $('#waitInfo').show();
    });
    $('#confirmWait').click(function() {
      var j, len, results, show;
      gameTime.incrementDays(parseInt($('#waitTimeInput').val()));
      if (parseInt($('#waitTimeInput').val()) !== 1) {
        gameEvents.addEvent(new event('', gameTime.getFormatted(), 'You wait ' + $('#waitTimeInput').val() + ' days'));
      } else {
        gameEvents.addEvent(new event('', gameTime.getFormatted(), 'You wait ' + $('#waitTimeInput').val() + ' day'));
      }
      results = [];
      for (j = 0, len = locations.length; j < len; j++) {
        location = locations[j];
        show = Math.floor(Math.random() * 30) <= parseInt($('#waitTimeInput').val()) / 2;
        if (show) {
          results.push(location.marker.setVisible(true));
        } else {
          results.push(void 0);
        }
      }
      return results;
    });
    $('#washPic').click(function() {
      var item, j, k, len, len1, notWashed, ref, ref1;
      notWashed = [];
      ref = mark.inventory;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (!item.washed) {
          notWashed.push(item);
        }
      }
      if (notWashed.length === 0) {
        $('#washPicOverlay p').text('There are no pictures to wash.');
        $('#washPicOverlay').show();
        return $('#washPicOverlay #confirmWashPic').hide();
      } else {
        ref1 = mark.inventory;
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          item = ref1[k];
          item.washed = true;
        }
        $('#washPicOverlay p').text('Washing photos takes ' + gameGlobal.turnConsts.pictureWashingTime + ' days. Proceed?');
        $('#washPicOverlay').show();
        return $('#washPicOverlay #confirmWashPic').show();
      }
    });
    $('#confirmWashPic').click(function() {
      gameTime.incrementTime(10 * Math.random());
      gameTime.incrementDays(gameGlobal.turnConsts.pictureWashingTime);
      return gameEvents.addEvent(new event('Washed pictures.', gameTime.getFormatted(), 'You wash all pictures in your camera.'));
    });
    $('#takeLoan').click(function() {
      $('#IR').text('Current interest rate ' + gameGlobal.turnConsts.interest + '%');
      return $('#loanOverlay').show();
    });
    $('#confirmLoan').click(function() {
      var newStats;
      newStats = mark.stats;
      newStats.liabilities += parseInt($('#loanInput').val()) + parseInt($('#loanInput').val()) * (gameGlobal.turnConsts.interest / 10);
      newStats.CAB += parseInt($('#loanInput').val());
      mark.updateStats(newStats);
      return gameEvents.addEvent(new event('Bank loan.', gameTime.getFormatted(), 'You take a bank loan of $' + parseInt($('#loanInput').val())));
    });
    $('#loanInput, #waitTimeInput').keyup(function() {
      if (!$.isNumeric($(this).val())) {
        $(this).parent().find('.err').text('*Input must be a number');
        return $(this).parent().find('button.confirm').prop('disabled', true);
      } else {
        $(this).parent().find('.err').text('');
        return $(this).parent().find('button.confirm').prop('disabled', false);
      }
    });
    $('#sellPic').click(function() {
      var j, len, photo, photosValue, ref, sellablePhotos;
      sellablePhotos = 0;
      photosValue = 0;
      ref = mark.inventory;
      for (j = 0, len = ref.length; j < len; j++) {
        photo = ref[j];
        if (photo.washed) {
          sellablePhotos += 1;
          photosValue += photo.value;
        }
      }
      $('#soldInfoOverlay p').text('Potential Earnings $' + parseInt(photosValue) + ' from ' + sellablePhotos + ' Photo/s');
      if (sellablePhotos === 0) {
        $('#soldInfoOverlay button').hide();
      } else {
        $('#soldInfoOverlay button').show();
      }
      return $('#soldInfoOverlay').show();
    });
    $('#sellPhotos').click(function() {
      var earningsAct, earningsEst, j, len, newInventory, newStats, photo, photosSold, ref, timeTaken;
      photosSold = 0;
      earningsEst = 0;
      earningsAct = 0;
      newInventory = [];
      newStats = mark.stats;
      ref = mark.inventory;
      for (j = 0, len = ref.length; j < len; j++) {
        photo = ref[j];
        if (photo.washed) {
          earningsAct += parseInt(photo.value + (photo.value * Math.random()));
          earningsEst += photo.value;
          photosSold += 1;
          gameGlobal.trackers.photosSold += 1;
          gameGlobal.trackers.moneyEarned += earningsAct;
        } else {
          newInventory.push(photo);
        }
      }
      timeTaken = ((Math.random() * 2) + 1) * photosSold;
      mark.inventory = newInventory;
      newStats.CAB += earningsAct;
      newStats.assets -= earningsEst;
      mark.updateStats(newStats);
      gameTime.incrementDays(parseInt(timeTaken));
      if (parseInt(timeTaken) === 1) {
        return gameEvents.addEvent(new event('Selling Pictures.', gameTime.getFormatted(), 'It took ' + parseInt(timeTaken) + ' day to finally sell everything. Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s.'));
      } else {
        return gameEvents.addEvent(new event('Selling Pictures.', gameTime.getFormatted(), 'It took ' + parseInt(timeTaken) + ' days to finally sell everything. Earned $' + earningsAct + ' from selling ' + photosSold + ' Photo/s.'));
      }
    });
    $('#actions button').click(function() {
      return $('#blockOverlay').show();
    });
    $('.confirm, .close').click(function() {
      return closeParent(this);
    });
    closeParent = function(self) {
      $(self).parent().hide();
      return $('#blockOverlay').hide();
    };
    $('#actions').draggable();
    $('#actions').mousedown(function() {
      return $('#actions p').text('Actions');
    });
  });

}).call(this);

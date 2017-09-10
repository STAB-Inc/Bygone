// Generated by CoffeeScript 1.12.7
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  jQuery(document).ready(function() {
    var deg2rad, distanceTravelled, endTurn, generateMarkers, interest, location, locations, mark, photo, photographyGame, player, processData, retrieveResources, setValue, updateMarkers;
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
    photographyGame = (function() {
      function photographyGame(debug, map1) {
        this.debug = debug;
        this.map = map1;
      }

      photographyGame.prototype.init = function() {};

      return photographyGame;

    })();
    location = (function() {
      function location(position, name, data1, icon) {
        this.position = position;
        this.name = name;
        this.data = data1;
        this.icon = icon;
        this.marker;
        this.value;
        this.travelExpense;
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
          $('#infoOverlay img').attr('src', self.data.img);
          $('#infoOverlay #title').text(self.data.title);
          $('#infoOverlay #description').text(self.data.description);
          $('#infoOverlay #position').text('Distance away ' + parseInt(distanceTravelled(mark.position, self.position)) + 'km');
          $('#infoOverlay #value').text('Potential Revenue $' + self.value);
          $('#infoOverlay #travelExpense').text('Travel Expense $' + parseInt((distanceTravelled(mark.position, self.position) * 0.6) / 10));
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
          icon: this.icon,
          title: this.name,
          optimized: false,
          zIndex: 100
        });
      };

      player.prototype.moveTo = function(location) {
        var newStats;
        console.log(location);
        console.log("current position", this.position, "new position", location.position, "distance travelled", distanceTravelled(this.position, location.position) + 'km');
        location.travelExpense = parseInt((distanceTravelled(this.position, location.position) * 0.6) / 10);
        this.position = location.position;
        this.playerAt = location;
        this.playerMarker.setPosition(new google.maps.LatLng(location.position.lat, location.position.lng));
        updateMarkers();
        $('#takePic').show();
        newStats = this.stats;
        newStats.workingCapital -= mark.playerAt.travelExpense;
        return this.updateStats(newStats);
      };

      player.prototype.updateStats = function(stats) {
        this.stats = stats;
        $('#infoOverlay #stats #workingCapital').text('Working Capital $' + parseInt(this.stats.workingCapital));
        $('#infoOverlay #stats #capital').text('Capital $' + parseInt(this.stats.assets - this.stats.liabilities));
        $('#infoOverlay #stats #assets').text('Current Assets $' + parseInt(this.stats.assets));
        return $('#infoOverlay #stats #liabilities').text('Current Liabilities $' + parseInt(this.stats.liabilities));
      };

      return player;

    })(location);
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
    photo = (function() {
      function photo(value1, washed, img, title) {
        this.value = value1;
        this.washed = washed;
        this.img = img;
        this.title = title;
      }

      return photo;

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
    locations = [];
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
        }, place[0], {
          'title': place['dc:title'],
          'description': place['dc:description'],
          'img': place['150_pixel_jpg']
        });
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
        return location.value = parseInt(Math.random() * distanceTravelled(mark.position, location.position) + 100);
      } else {
        return location.value = parseInt((Math.random() * distanceTravelled(mark.position, location.position) + 100) / 10);
      }
    };
    mark = new player({
      lat: -25.363,
      lng: 151.044
    }, 'Mark', {
      'type': 'self'
    }, 'https://developers.google.com/maps/documentation/javascript/images/custom-marker.png');
    mark.initTo(googleMap);
    mark.updateStats({
      'workingCapital': 1000,
      'assets': 0,
      'liabilities': 300
    });
    retrieveResources(parseInt(Math.random() * (100 - 20) + 20)).then(function(res) {
      return generateMarkers(processData(res));
    });
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
    interest = 1.5;
    endTurn = function() {
      var j, len, newStats;
      newStats = mark.stats;
      newStats.workingCapital -= mark.stats.liabilities;
      mark.updateStats(newStats);
      for (j = 0, len = locations.length; j < len; j++) {
        location = locations[j];
        location.marker.setVisible(true);
      }
      interest = (Math.random() * 5).toFixed(2);
      return console.log(interest);
    };
    $('#takePic').click(function() {
      var newStats, shotTaken;
      shotTaken = new photo(mark.playerAt.value, false, mark.playerAt.data.img, mark.playerAt.data.title);
      mark.inventory.push(shotTaken);
      mark.playerAt.marker.setVisible(false);
      newStats = mark.stats;
      newStats.assets += mark.playerAt.value;
      newStats.workingCapital -= mark.playerAt.travelExpense / 2;
      mark.updateStats(newStats);
      return $('#takePic').hide();
    });
    $('#checkInv').click(function() {
      var item, j, len, ref, value;
      $('#inventory').show();
      $('#inventory .photo').remove();
      value = 0;
      ref = mark.inventory;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        $('<img class="photo" src=' + item.img + '" value="' + item.value + '"/>').appendTo($('#inventory'));
        value += item.value;
      }
      return $('#invValue').text('Photo value $' + value);
    });
    $('.close').click(function() {
      return $(this).parent().hide();
    });
    $('#endTurn').click(function() {
      return endTurn();
    });
    $('#washPic').click(function() {
      var item, j, len, newStats, ref, totalValue;
      if (mark.inventory.length === 0) {
        return alert('There are no pictures to wash');
      } else {
        newStats = mark.stats;
        totalValue = 0;
        ref = mark.inventory;
        for (j = 0, len = ref.length; j < len; j++) {
          item = ref[j];
          totalValue += item.value;
        }
        newStats.workingCapital += totalValue;
        newStats.assets -= totalValue;
        mark.updateStats(newStats);
        mark.inventory = [];
        return endTurn();
      }
    });
    $('#takeLoan').click(function() {
      $('#IR').text('Current interest rate ' + interest + '%');
      return $('#loanOverlay').show();
    });
    $('#confirmLoan').click(function() {
      var newStats;
      console.log($('#loanInput').val(), parseInt($('#loanInput').val()) * (interest / 10));
      newStats = mark.stats;
      newStats.liabilities += parseInt($('#loanInput').val()) + parseInt($('#loanInput').val()) * (interest / 10);
      newStats.workingCapital += parseInt($('#loanInput').val());
      console.log(typeof newStats.workingCapital);
      return mark.updateStats(newStats);
    });
  });

}).call(this);

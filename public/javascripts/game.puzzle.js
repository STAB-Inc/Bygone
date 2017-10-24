// Generated by CoffeeScript 1.12.7

/*
@file
Handles the functionality of the puzzle game.
 */

(function() {
  jQuery(document).ready(function() {

    /*
      Submits session data to the server. 
      @param {object} data - the data to be submitted.
      @return AJAX deferred promise.
     */
    var currentGame, getParam, load, processData, puzzleGame, retrieveResources, storyMode, submitUserData;
    submitUserData = function(data) {
      return $.ajax({
        url: '/routes/user.php',
        type: 'POST',
        data: data
      });
    };

    /*
      Gets the value of the paramater in the query string of a GET request.
      @param {string} name - the key of the corrosponding value to retrieve.
      @return The sorted array.
     */
    getParam = function(name) {
      var results;
      results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
      return results[1] || 0;
    };
    puzzleGame = (function() {

      /*
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
       */
      function puzzleGame(debug, xsplit, ysplit, amount1) {
        this.debug = debug;
        this.xsplit = xsplit;
        this.ysplit = ysplit;
        this.amount = amount1;
        this.attempts = 0;
      }


      /*
        Initialize the game.
      
        @param {array} resources
          The array of resources for the game to generate from.
       */

      puzzleGame.prototype.init = function(resources) {
        var resourceLimit;
        this.resources = resources;
        this.resources.sort(function() {
          return 0.5 - Math.random();
        });
        resourceLimit = this.resources.slice(0, this.amount);
        this.solution = resourceLimit[Math.floor(Math.random() * resourceLimit.length)];
        this.reset();
        this.generateChoiceField(resourceLimit);
        this.generateTiles();
        return this.initTimer();
      };


      /*
        Initialize the timer.
       */

      puzzleGame.prototype.initTimer = function() {
        var counter, time;
        time = 0;
        counter = function() {
          time += 1;
          $('#timer').text('Time: ' + time);
          return $('#timer').attr('value', time);
        };
        return this.timer = setInterval(counter, 1000);
      };


      /*
        Generates the puzzle tiles.
       */

      puzzleGame.prototype.generateTiles = function() {
        var col, i, imgHeight, imgWidth, row, tile, tileHeight, tileTemplate, tileWidth, tiles;
        tileTemplate = $('#tileTemplate');
        tiles = this.xsplit * this.ysplit;
        imgWidth = $('#tileTemplate').width();
        imgHeight = $('#tileTemplate').height();
        tileWidth = imgWidth / this.xsplit;
        tileHeight = imgHeight / this.ysplit;
        i = 0;
        col = 0;
        while (col < this.ysplit) {
          row = 0;
          while (row < this.xsplit) {
            tile = $(tileTemplate.clone());

            /*
              jQuery UI draggable plugin.
             */
            tile.draggable({
              snap: true,
              snapMode: "both"
            });
            tile.show();
            tile.addClass('tile');
            tile.removeAttr('id', '');
            tile.css({
              'background-image': 'url(' + this.solution['High resolution image'] + ')',
              'background-position': -row * tileWidth + 'px ' + -col * tileHeight + 'px',
              'width': tileWidth,
              'height': tileHeight,
              'left': Math.floor(Math.random() * 100) + 'px',
              'top': Math.floor(Math.random() * 100) + 'px'
            });
            $('#gameArea').append(tile);
            i++;
            row++;
            if (this.debug) {
              console.log('created', i, 'tile at', row - 1, col);
            }
          }
          col++;
        }
        tileTemplate.hide();
        if (this.debug) {
          console.log('--- Width', imgWidth, 'Height', imgHeight, 'TileWidth', tileWidth, 'TileHight', tileHeight);
          return console.log('solution', this.getAnswer());
        }
      };


      /*
        Generates the avaliable choices for the user.
        @param {array} choices
          The set of choices to generate from.
       */

      puzzleGame.prototype.generateChoiceField = function(choices) {
        var choice, i, j, len, results1;
        i = 1;
        results1 = [];
        for (j = 0, len = choices.length; j < len; j++) {
          choice = choices[j];
          if (choice === this.solution) {
            $('#selectionArea').append('<div class="choice" id="choice' + i + '"><img class="img-responsive" src="' + choice['Thumbnail image'] + '"</div>');
            this.setAnswerValue(i);
          } else {
            $('#selectionArea').append('<div class="choice" id="choice' + i + '"><img class="img-responsive" src="' + choice['Thumbnail image'] + '"</div>');
          }
          results1.push(i++);
        }
        return results1;
      };


      /*
        Sets the index value of the solution.
       */

      puzzleGame.prototype.setAnswerValue = function(value) {
        return this.solutionValue = value;
      };


      /*
        Gets the current answer
        @return
          The array of the solution and its corrosponding index.
       */

      puzzleGame.prototype.getAnswer = function() {
        return [this.solution, this.solutionValue];
      };


      /*
        Resets the game.
       */

      puzzleGame.prototype.reset = function() {
        $('#selectionArea, #gameArea').empty();
        clearInterval(this.timer);
        return this.time = 0;
      };


      /*
        Display the game win screen.
       */

      puzzleGame.prototype.gameWin = function() {
        this.score = (300 * this.amount) - parseInt($('#timer').attr('value')) - (1000 * this.attempts);
        $('.winScreen .timeTaken').text('Time taken : ' + $('#timer').attr('value') + ' seconds');
        $('.winScreen .finalScore').text('Your score : ' + this.score + ' pts');
        $('.winScreen').show();
        $('.winScreen img').attr('src', this.solution['High resolution image']);
        $('.winScreen .soldierName').text(this.solution['Full name (from National Archives of Australia)']);
        $('.winScreen .soldierDesc').text(this.solution['Title of image']);
        $('.play').show();
        return this.reset();
      };


      /*
        Increment the attempts each time a incorrect choice is made.
       */

      puzzleGame.prototype.gameLose = function() {
        this.attempts += 1;
        return $('#attempts').text('Attempts: ' + this.attempts);
      };


      /*
        Saves the current user score.
       */

      puzzleGame.prototype.saveScore = function() {
        return submitUserData({
          method: 'saveScore',
          gameId: '1',
          value: this.score
        }).then(function(res) {
          res = JSON.parse(res);
          if (res.status === 'success') {
            return $('.winScreen .status').text(res.message);
          }
        });
      };


      /*
        Saves the a item to the user's collection.
       */

      puzzleGame.prototype.saveItem = function() {
        return submitUserData({
          method: 'saveItem',
          image: this.solution['High resolution image'],
          description: this.solution['Title of image']
        }).then(function(res) {
          res = JSON.parse(res);
          if (res.status === 'success') {
            return $('.winScreen .status').text(res.message);
          }
        });
      };

      return puzzleGame;

    })();

    /*
      Retrieves resources from the dataset.
      @param {integer} amount
        The amount of resources to retrieve.
    
      @return
        AJAX deferred promise.
     */
    retrieveResources = function(amount) {
      var reqParam;
      reqParam = {
        resource_id: 'cf6e12d8-bd8d-4232-9843-7fa3195cee1c',
        limit: amount
      };
      return $.ajax({
        url: 'https://data.gov.au/api/action/datastore_search',
        data: reqParam,
        dataType: 'jsonp',
        cache: true
      });
    };

    /*
      Processes and validates an array of data.
      @param {array} data
        The set of data to process.
    
      @return
        The array of processed data.
     */
    processData = function(data) {
      var item, j, len, processedData, ref;
      processedData = [];
      ref = data.result.records;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (item['High resolution image']) {
          processedData.push(item);
        }
      }
      return processedData;
    };

    /*
      Loads the page by removing the loading screen.
     */
    load = function() {
      $('#loader').css({
        'opacity': 0,
        'pointer-events': 'none'
      });
      $('body').css('overflow-y', 'auto');
      return setTimeout(function() {
        return $('#loader').css({
          'display': 'none',
          'left': -1 * $('#loader').width()
        });
      }, 1000);
    };

    /*
      Retrieves the GET paramater from the query string. Sets up the interface and constructs the Puzzle game object accordingly.
     */
    try {
      storyMode = getParam('story') === 'true';
      if (storyMode) {
        $('#playAgain').text('Continue');
        $('#playAgain').parent().attr('href', 'chapter2.html');
        $('.skip').show();
        $('.save').hide();
        $('#playAgain').addClass('continue');
      }
      switch (getParam('diff')) {
        case "easy":
          currentGame = new puzzleGame(false, 4, 4, 20);
          break;
        case "normal":
          currentGame = new puzzleGame(false, 8, 8, 30);
          break;
        case "hard":
          currentGame = new puzzleGame(false, 12, 12, 50);
          break;
        default:
          currentGame = new puzzleGame(false, 4, 4, 20);
      }

      /*
        Initialize the game.
        @see retrieveResources()
        @see processData()
        @see puzzleGame.prototype.init()
       */
      retrieveResources(1000).then(function(res) {
        load();
        return currentGame.init(processData(res));
      });
    } catch (error) {}

    /*
      Skips the game when in story mode. Completes the chapter for the user.
     */
    $('.skip, .continue').click(function(e) {
      $('.continueScreen').show();
      $('#selectionArea, #gameArea').hide();
      return submitUserData({
        method: 'chapterComplete',
        chapterId: '1'
      }).then(function(res) {
        res = JSON.parse(res);
        if (res.status === 'success') {

        }
      });
    });

    /*
      Saves the current score.
      @see puzzleGame.prototype.saveScore()
     */
    $('#saveScore').click(function() {
      return currentGame.saveScore();
    });

    /*
      Saves the item to the user's collection.
      @see puzzleGame.prototype.saveItem()
     */
    $('#saveItem').click(function() {
      return currentGame.saveItem();
    });

    /*
      Disables the save button.
     */
    $('.save').click(function() {
      return $(this).prop('disabled', true);
    });
    $('.winScreen').hide();

    /*
      Binds click event to choices generated after the DOM has been loaded.
     */
    $('#selectionArea').on('click', '.choice', function() {
      if (parseInt($(this).attr('id').match(/[0-9]+/)) === currentGame.getAnswer()[1]) {
        currentGame.gameWin();
      } else {
        currentGame.gameLose();
      }
    });

    /*
      Refreshes the page.
     */
    $('#playAgain').click(function() {
      return location.reload();
    });

    /*
      Resets the game.
     */
    $('#reset').click(function() {
      return currentGame.reset();
    });
  });

}).call(this);

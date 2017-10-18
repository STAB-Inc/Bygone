###
@file
Generates the appropiate view for highscores.html
###

$(document).ready ->

  ###
    Sorts an array by the first element of the array.
  ###

  sortDec = (a, b) ->
    if a[0] == b[0] then return 0 else return a[0] < b[0] ? -1 : 1

  ###
    Submits session data to the server. 
    @param {Object} data - the data to be submitted.
    @return AJAX deferred promise.
  ###

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data

  ###
    Generates the elements containing the highscores info by requesting the apporiate data.
  ###

  submitUserData({
    method: 'getAll'
  }).then (res) ->
    userData = JSON.parse res
    submitUserData({
      method: 'getActiveUser'
    }).then (user) ->
      user = JSON.parse user
      userId = user.message
      gameScore = {
        g1: []
        g2: []
        g3: []
        g4: []
      }
      for key in Object.keys gameScore
        for data in userData
          for scores in data.scores[key]
            gameScore[key].push [parseInt(scores[0]), scores[1], data.username, data.id]
        for score in gameScore[key].sort sortDec
          if userId == score[3]
            $('.' + key).append $('<div class="row current">
                                    <div class="col-lg-4">
                                    <p>' + score[2] + '</p>
                                    </div>
                                    <div class="col-lg-4">
                                      <p>' + score[0] + '</p>
                                    </div>
                                    <div class="col-lg-4">
                                      <p class="date">' + score[1] + '</p>
                                    </div>
                                  </div>')
          else
            $('.' + key).append $('<div class="row">
                          <div class="col-lg-4">
                          <p>' + score[2] + '</p>
                          </div>
                          <div class="col-lg-4">
                            <p>' + score[0] + '</p>
                          </div>
                          <div class="col-lg-4">
                            <p class="date">' + score[1] + '</p>
                          </div>
                        </div>')
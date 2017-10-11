$(document).ready ->

  submitUserData = (data) ->
    $.ajax
      url: '/routes/user.php'
      type: 'POST'
      data: data

  submitUserData({
    method: 'getAll'
  }).then (res) ->
    userData = JSON.parse res
    g1Data = []
    g2Data = []
    g3Data = []
    g4Data = []
    for data in userData
      for scores in data.scores.g1
        g1Data.push [scores[0], scores[1], data.username]
      for scores in data.scores.g2
        g2Data.push [scores[0], scores[1], data.username]
      for scores in data.scores.g3
        g3Data.push [scores[0], scores[1], data.username]
      for scores in data.scores.g4
        g4Data.push [scores[0], scores[1], data.username]

    sortDec = (a, b) ->
      if a[0] == b[0] then return 0 else return a[0] < b[0] ? -1 : 1

    g1Data.sort(sortDec)

    for score in g1Data.sort sortDec
      $('.g1').append $('<div class="col-lg-4">
                          <p>' + score[2] + '</p>
                          </div>
                          <div class="col-lg-4">
                            <p>' + score[0] + '</p>
                          </div>
                          <div class="col-lg-4">
                            <p class="date">' + score[1] + '</p>
                        </div>')

    console.log g1Data, g2Data

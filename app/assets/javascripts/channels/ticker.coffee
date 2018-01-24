App.room = App.cable.subscriptions.create "TickerChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    document.getElementById(data.pair + '-last').innerText = data.last
    document.getElementById(data.pair + '-high').innerText = data.high
    document.getElementById(data.pair + '-low').innerText = data.low
    console.log(data)
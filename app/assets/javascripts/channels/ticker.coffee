App.room = App.cable.subscriptions.create "TickerChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    la = document.getElementById(data.pair + '-last')
    if (la)
      la.innerText = data.last
    hi = document.getElementById(data.pair + '-high')
    if (hi)
      hi.innerText = data.high
    lo = document.getElementById(data.pair + '-low')
    if (lo)
      lo.innerText = data.low
    console.log(data)
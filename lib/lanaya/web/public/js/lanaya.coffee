class Lanaya
  constructor: ->
    @refresh()
    @subscribe()

  subscribe: ->
    if WebSocket?
      @subscribeWebSocket()
    else
      @subscribePoll()

  subscribeWebSocket: ->
    secure = window.location.scheme == 'https'
    uri = "#{if secure then 'wss' else 'ws'}://#{window.location.host}/interactions"
    @websocket = new WebSocket(uri)
    @websocket.onmessage = (event) =>
      @addInteraction $.parseJSON(event.data)

  subscribePoll: ->
    unless @refreshInterval?
      @refreshInterval = setInterval (=> @refresh()), 1000

  refresh: ->
    $.getJSON '/interactions', (interactions) =>
      $.each(interactions, (i, interaction) =>
        unless @haveInteraction(interaction)
          @addInteraction interaction
      )

  haveInteraction: (interaction) ->
    false

  addInteraction: (interaction) ->
    console.log(interaction)


jQuery ->
  window.Lanaya = new Lanaya

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
    $("#interaction-#{interaction.session_id}").length > 0

  addInteraction: (interaction) ->
    console.log(interaction)
    html = """
      <tr id="interaction-#{interaction.session_id}" class="interaction" >
        <td>#{interaction.request.uri}</td>
        <td>#{interaction.request.method}</td>
        <td>#{interaction.response.status_code}</td>
        <td>#{interaction.response.content_type}</td>
        <td>#{interaction.requested_at }</td>
      </tr>
    """
    $('#interactions table tbody').append(html)


jQuery ->
  window.Lanaya = new Lanaya

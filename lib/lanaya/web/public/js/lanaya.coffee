class Lanaya
  constructor: ->
    @initFoundation()
    @bindEvents()
    @refresh()
    @subscribe()

  initFoundation: ->
    $(window.document).foundation()

  bindEvents: ->
    _this = this
    $(window.document).on 'click', '.interaction', (event) ->
      interaction = $(this).data()
      _this.displayInterationDetail(interaction)
      $('#interaction-detail').data('session-id', interaction.session_id).show()

    $('#interaction-detail .close').on 'click', (event) ->
      $('#interaction-detail').hide()

  displayInterationDetail: (interaction) ->
    @displayInteractionHeaders(interaction)
    $.get("/#{interaction.session_id}/response_body", (response) =>
      @displayInteractionPreview(response)
      @displayInteractionResponse(response)
    )

  displayInteractionHeaders: (interaction) ->
    tpl = """
    <div id="interation-summary">
      <ul>
        <li><b>Request URL:</b> <%= interaction.request.uri %></li>
        <li><b>Request Method:</b> <%= interaction.request.method %></li>
        <li><b>Status Code:</b> <%= interaction.response.status_code %></li>
        <li>
          <b>Request Headers</b>
          <ul>
            <% _.each(interaction.request.headers, function(value, key) { %>
              <li><b><%= key %>:</b> <%= value %></li>
            <% }); %>
          </ul>
        </li>
        <li>
          <b>Reponse Headers</b>
          <ul>
            <% _.each(interaction.response.headers, function(value, key) { %>
              <li><b><%= key %>:</b> <%= value %></li>
            <% }); %>
          </ul>
        </li>
      </ul>
    </div>
    """
    html = _.template(tpl)({ interaction: interaction })
    $('#interaction-detail #headers').html(html)

  displayInteractionResponse: (response) ->
    response = 'This request has no response data available.' if response == ''
    $('#response').text(response)

  displayInteractionPreview: (response) ->
    if response == ''
      response = 'This request has no response data available.'
      $('#preview').html(response)
    else
      $iframe = $("<iframe></iframe>")
      $iframe.css({width: '100%', height: '100%'})
      $('#preview').html($iframe)
      iframe = $iframe[0]
      frameDoc = iframe.document
      # IE
      frameDoc = iframe.contentWindow.document if iframe.contentWindow
      frameDoc.open()
      frameDoc.writeln(response)
      frameDoc.close()

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
    $html = $(html).data(interaction)
    $('#interactions table tbody').append($html)

jQuery ->
  window.Lanaya = new Lanaya

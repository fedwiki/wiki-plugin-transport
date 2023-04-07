
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

beam = (url) ->
  $.getJSON url, (page) ->
    resultPage = wiki.newPage(page)
    wiki.showResult resultPage

graphData = ($item) ->
  graphs = []
  candidates = $(".item:lt(#{$('.item').index($item)})")
  for each in candidates
    if $(each).hasClass 'graph-source'
      graphs.push each.graphData()
  graphs

graphStats = ($item) ->
  graphs = nodes = arcs = 0
  candidates = $(".item:lt(#{$('.item').index($item)})")
  for each in candidates
    if $(each).hasClass 'graph-source'
      graphs += 1
      for node, arc of each.graphData()
        nodes += 1
        arcs += arc.length
  {graphs, nodes, arcs}

report = (object) ->
  """<pre style="text-align: left; background-color:#ddd; padding:8px;"">#{JSON.stringify object, null, '  '}</pre>"""

options = (text) ->
  domain = m[1] if m = text.match /(https?:\/\/.*?\/)/
  post = m[1] if m = text.match /\bPOST\b\s*(.*)/
  graph = !!text.match /\bGRAPH\b/
  {domain, post, graph}

emit = ($item, item) ->
  opt = options item.text
  $item.append """
    <div style="background-color:#eee;padding:15px;text-align:center;">
      <div class=preview>
      </div>
      <p class=transport-action>
        transporting through<br>
        #{expand item.text}
      </p>
      <p class=caption>
        unavailable
      </b>
    </div>
  """
  if opt.domain
    $.get opt.domain, ->
      $item.find('.caption').text 'ready'
  if opt.graph
    $item.find('.preview').html report graphStats($item)
    $item.find('.transport-action').append "<p><button>Beam Up</button></p>"

bind = ($item, item) ->
  opt = options item.text
  $item.on 'dblclick', () -> wiki.textEditor $item, item

  $item.find('button').on 'click', (e) ->
     post e, graphData($item)

  $item.on 'drop', (e) ->
    e.preventDefault()
    e.stopPropagation()
    post e,
      text: e.originalEvent.dataTransfer.getData("text")
      html: e.originalEvent.dataTransfer.getData("text/html")
      url:  e.originalEvent.dataTransfer.getData("URL")

  post = (e, params) ->
    $item.find('.caption').text 'waiting'
    $page = $item.parents('.page') unless e.shiftKey

    req =
      type: "POST",
      url: opt.post
      dataType: 'json',
      contentType: "application/json",
      data: JSON.stringify(params)

    $.ajax(req).done (page) ->
      $item.find('.caption').text 'ready'
      resultPage = wiki.newPage(page)
      wiki.showResult resultPage, {$page}


window.plugins.transport = {emit, bind} if window?
module.exports = {expand} if module?

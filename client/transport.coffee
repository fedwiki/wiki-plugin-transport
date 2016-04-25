
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
  for $each in candidates
    $each = $($each)
    if $each.hasClass 'graph-source'
       graphs.push $each.get(0).graphData()
  graphs

report = (object) ->
  """<pre style="text-align: left; background-color:#fff; padding:8px;"">#{JSON.stringify object, null, '  '}</pre>"""


emit = ($item, item) ->
  $item.append """
    <div style="background-color:#eee;padding:15px;text-align:center;">
      <div class=preview>
        #{report graphData($item)}
      </div>
      <p>
        transporting through<br>
        #{expand item.text}<br>
        <button>Beam Up</button>
      </p>
      <p class=caption>
        unavailable
      </b>
    </div>
  """
  if match = item.text.match /(https?:\/\/.*?\/)/
    $.get match[1], ->
      $item.find('.caption').text 'ready'

bind = ($item, item) ->
  $item.dblclick -> wiki.textEditor $item, item

  $item.find('button').click ->
    post graphData($item)

  $item.on 'drop', (e) ->
    e.preventDefault()
    e.stopPropagation()
    post
      text: e.originalEvent.dataTransfer.getData("text")
      html: e.originalEvent.dataTransfer.getData("text/html")
      url:  e.originalEvent.dataTransfer.getData("URL")

  post = (params) ->
    console.log 'params',params
    $item.find('.caption').text 'waiting'
    $page = $item.parents('.page')

    req =
      type: "POST",
      url: item.text.replace(/^POST\s*/,'')
      dataType: 'json',
      contentType: "application/json",
      data: JSON.stringify(params)

    $.ajax(req).done (page) ->
      $item.find('.caption').text 'ready'
      console.log 'page', page
      resultPage = wiki.newPage(page)
      wiki.showResult resultPage, {$page}


window.plugins.transport = {emit, bind} if window?
module.exports = {expand} if module?

const expand = text => {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\*(.+?)\*/g, '<i>$1</i>')
}

const beam = url => {
  $.getJSON(url, page => {
    const resultPage = wiki.newPage(page)
    wiki.showResult(resultPage)
  })
}

const graphData = $item => {
  const graphs = []
  const candidates = $(`.item:lt(${$('.item').index($item)})`)
  for (const each of candidates) {
    if ($(each).hasClass('graph-source')) {
      graphs.push(each.graphData())
    }
  }
  return graphs
}

const graphStats = $item => {
  let graphs = 0,
    nodes = 0,
    arcs = 0
  const candidates = $(`.item:lt(${$('.item').index($item)})`)
  for (const each of candidates) {
    if ($(each).hasClass('graph-source')) {
      graphs += 1
      for (const [node, arc] of each.graphData()) {
        nodes += 1
        arcs += arc.length
      }
    }
  }
  return { graphs, nodes, arcs }
}
const report = object => {
  return `<pre style="text-align: left; background-color:#ddd; padding:8px;"">${JSON.stringify(object, null, '  ')}</pre>`
}
const options = text => {
  let m = []
  const domain = (m = text.match(/(https?:\/\/.*?\/)/)) ? m[1] : null
  const post = (m = text.match(/\bPOST\b\s*(.*)/)) ? m[1] : null
  const graph = !!text.match(/\bGRAPH\b/)
  return { domain, post, graph }
}
const emit = ($item, item) => {
  const opt = options(item.text)
  $item.append(`
    <div style="background-color:#eee;padding:15px;text-align:center;">
      <div class="preview">
      </div>
      <p class="transport-action">
        transporting through<br>
        ${expand(item.text)}
      </p>
      <p class="caption">
        unavailable
      </b>
    </div>
  `)
  if (opt.domain) {
    $.get(opt.domain, () => {
      $item.find('.caption').text('ready')
    })
  }
  if (opt.graph) {
    $item.find('.preview').html(report(graphStats($item)))
    $item.find('.transport-action').append('<p><button>Beam Up</button></p>')
  }
}
const bind = ($item, item) => {
  const opt = options(item.text)
  $item.on('dblclick', () => wiki.textEditor($item, item))

  $item.find('button').on('click', e => {
    post(e, graphData($item))
  })

  $item.on('drop', e => {
    e.preventDefault()
    e.stopPropagation()
    post(e, {
      text: e.originalEvent.dataTransfer.getData('text'),
      html: e.originalEvent.dataTransfer.getData('text/html'),
      url: e.originalEvent.dataTransfer.getData('URL'),
    })
  })
  const post = (e, params) => {
    $item.find('.caption').text('waiting')
    const $page = !e.shiftKey ? $item.parents('.page') : null

    const req = {
      type: 'POST',
      url: opt.post,
      dataType: 'json',
      contentType: 'application/json',
      data: JSON.stringify(params),
    }
    $.ajax(req).done(page => {
      $item.find('.caption').text('ready')
      const resultPage = wiki.newPage(page)
      wiki.showResult(resultPage, { $page })
    })
  }
}

if (typeof window !== 'undefined') {
  window.plugins.transport = { emit, bind }
}

export const transport = typeof window == 'undefined' ? { expand } : undefined

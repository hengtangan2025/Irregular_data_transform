class SaveAndQueryJsons
  constructor: (@$eml) ->
    @bind_event()

  updateGraph = ->
    console.log(1)
    if worker
      worker.terminate()
    document.querySelector('#output').classList.add 'working'
    document.querySelector('#output').classList.remove 'debugInfo'
    @worker = new Worker('/worker.js')

  worker.onmessage = (e) ->
    document.querySelector('#output').classList.remove 'working'
    document.querySelector('#output').classList.remove 'debugInfo'
    gvResult = e.data
    @updateOutput()


  worker.onerror = (e) ->
    document.querySelector('#output').classList.remove 'working'
    document.querySelector('#output').classList.add 'debugInfo'
    message = if e.message == undefined then '在生成思维引导图的过程中发生了错误。' else e.message
    debugInfo = document.querySelector('#debugInfo')
    while debugInfo.firstChild
      debugInfo.removeChild debugInfo.firstChild
    document.querySelector('#debugInfo').appendChild document.createTextNode(message)
    console.error e
    e.preventDefault()

  params = 
    src: document.getElementById('hintPipes').innerText
    options:
      engine: 'dot'
      format: 'svg'
  # Instead of asking for png-image-element directly, which we can't do in a worker,
  # ask for SVG and convert when updating the output.
  if params.options.format == 'png-image-element'
    params.options.format = 'svg'
  worker.postMessage params

updateOutput = ->
  graph = @$eml.find(".query_blank_results").val()
  svg = graph.querySelector('svg')
  if svg
    graph.removeChild svg
  if !gvResult
    return
  svg = gvParser.parseFromString(gvResult, 'image/svg+xml')
  graph.appendChild svg.documentElement


  bind_event: ->
    @$eml.on "click", ".save-json-btn",=>
      save_json_value = @$eml.find('.save_json_blank').val()
      $.ajax
        url: "/json_datas",
        method: "post",
        data: {save_json: save_json_value }
      .success (msg) =>
       alert msg

    @$eml.on "click", ".query-json-btn",=>
      query_json_value = @$eml.find('.query_blank').val()
      $.ajax
        url: "/irregular_data_transforms/query_json",
        method: "post",
        data: {query_json: query_json_value }
      .success (msg) =>
       output = 'digraph 关于“' + query_json_value + '”的思维引导图 { \n' +
         '  rankdir=LR\n' +
         '  graph [fontname="simhei" splines="polyline"]\n' +
         '  edge  [fontname="simhei" arrowsize="0.6"]\n' +
         '  node  [fontname="simhei" fontsize="9px" shape="note" height="0.1" style="filled" fillcolor="khaki1"] \n';
       for i in [0..msg.length - 1]
        output +=
          msg[i]["inPort"] +
          " -> " +
          msg[i]["outPort"] +
          "\n"
       output += '} '
       @$eml.find(".query_blank_results").val(output)
       @updateGraph()

jQuery(document).on "ready page:load", ->
  if jQuery(".page-save-and-query-jsons").length > 0
    new SaveAndQueryJsons jQuery(".page-save-and-query-jsons")
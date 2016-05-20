class QueryMindPhotograph
  constructor: (@$eml) ->
    @gvParser = new DOMParser();
    @gvResult;
    @bind_event()

  updateGraph: =>
    if @worker
      @worker.terminate()

    document.querySelector("#output").classList.add("working");
    document.querySelector("#output").classList.remove("debugInfo");

    @worker = new Worker("/x.js");

    @worker.onmessage = (e) =>
      document.querySelector("#output").classList.remove("working");
      document.querySelector("#output").classList.remove("debugInfo");
      @gvResult = e.data;
      @updateOutput();

    @worker.onerror = (e) =>
      alert('work error')
      console.log(e)

      document.querySelector("#output").classList.remove("working");
      document.querySelector("#output").classList.add("debugInfo");
      message = e.message == undefined ? "在生成思维引导图的过程中发生了错误。" : e.message;
      debugInfo = document.querySelector("#debugInfo");

      while debugInfo.firstChild
        debugInfo.removeChild(debugInfo.firstChild);
      document.querySelector("#debugInfo").appendChild(document.createTextNode(message));
      # console.error(e);
      e.preventDefault();

    params = {
      src: document.getElementById("hintPipes").innerText,
      options: {
        engine: "dot",
        format: "svg"
      }
    }

    if params.options.format is "png-image-element"
      params.options.format = "svg";

    @worker.postMessage(params)

  updateOutput: =>
    graph = document.querySelector("#output");
    svg = graph.querySelector("svg");
    if svg
      graph.removeChild(svg)
    if !@gvResult
      return;
    svg = @gvParser.parseFromString(@gvResult, "image/svg+xml")
    graph.appendChild(svg.documentElement)


  renderHintsNetGraph: (hintPipeSet,searchKeyword) =>
    hintPipeSetJson = JSON.parse(hintPipeSet);
    numOfHintPipes = hintPipeSetJson.length;
    @$eml.find("#find_result").text("找到"+numOfHintPipes+"条思路")
    output = 'digraph 关于“' + searchKeyword + '”的思维引导图 { \n' +
      '  rankdir=LR\n' +
      '  graph [fontname="simhei" splines="polyline"]\n' +
      '  edge  [fontname="simhei" arrowsize="0.6"]\n' +
      '  node  [fontname="simhei" fontsize="9px" shape="note" height="0.1" style="filled" fillcolor="khaki1"] \n';
    for i in [0...numOfHintPipes]
      output +=
        hintPipeSetJson[i]["inPort"] +
        " -> " +
        hintPipeSetJson[i]["outPort"] +
        '[label="..." labeltooltip="' + hintPipeSetJson[i]["purposeTags"] + '"]' + 
        "\n";
    document.getElementById("hintPipes").innerHTML = output + '} ';
    @updateGraph();

  bind_event: ->
    @$eml.on "click", ".query-json-btn",=>
      query_json_value = @$eml.find('.query_blank').val()
      $.ajax
        url: "/irregular_data_transforms/query_json",
        method: "post",
        data: {query_json: query_json_value }
      .success (msg) =>
        @renderHintsNetGraph(msg.result,query_json_value)

jQuery(document).on "ready page:load", ->
  if jQuery(".page-query-mind-photograph").length > 0
    new QueryMindPhotograph jQuery(".page-query-mind-photograph")
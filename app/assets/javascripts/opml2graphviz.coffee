class Opml2graphviz
  constructor: (@$eml) ->
    @gvParser = new DOMParser();
    @gvResult;
    @bind_event()
    @coupe_arys = []

  replace_chars: (text)->
    text1 = @replaceSpecialChar(text, '\\\\(?!n)(?!t)', '\\/')
    text2 = @replaceSpecialChar(text1, '\t', '  ')
    text3 = @replaceSpecialChar(text2, '\n', '\\n')
    text4 = @replaceSpecialChar(text3, '"', '\\"')
    text5 = @replaceSpecialChar(text4, '\'', '\\"')
    text6 = @replaceSpecialChar(text5, ':', '：')
    return text6

  replaceSpecialChar: (text, specialChar, safeChar)->
    patternInRegexp = new RegExp(specialChar, 'g')
    return text.replace(patternInRegexp, safeChar)

  make_coupe_arrays:(ary)=>
    if ary.length>1
      for i in [0...ary.length-1]
        @coupe_arys.push([ary[i]["-text"],ary[i+1]["-text"]])

    for i in [0...ary.length]
      if ary[i]['outline'] != undefined
        if ary[i]['outline'] instanceof Array
          child_ary = ary[i]['outline'] 
          @coupe_arys.push([ary[i]["-text"],ary[i]['outline'][0]["-text"]])
          @coupe_arys.push([ary[i]['outline'][child_ary.length-1]["-text"],ary[i+1]["-text"]])
          @make_coupe_arrays(child_ary)
        else
          child_obj = ary[i]['outline'] 
          @coupe_arys.push([ary[i]["-text"],child_obj["-text"]])
          @coupe_arys.push([child_obj["-text"],ary[i+1]["-text"]])
          @make_coupe_arrays(child_obj)

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

  hintPipeAddColor: (hintPipeObjWithNumber)->
    switch hintPipeObjWithNumber
      when 10 then TextWithColor = "#030387"
      when 9 then TextWithColor = "#181891"
      when 8 then TextWithColor = "#2D2D9B" 
      when 7 then TextWithColor = "#4242A5" 
      when 6 then TextWithColor = "#5757AF"
      when 5 then TextWithColor = "#6C6CB9"
      when 4 then TextWithColor = "#8181C3" 
      when 3 then TextWithColor = "#9696CD"
      when 2 then TextWithColor = "#ABABD7"
      when 1 then TextWithColor = "#C0C0E1"
    
    return TextWithColor

  hintPipeAddNumber: (hintPipeObjArray,i)->
    listMap = { }
    for hintPipeObj in hintPipeObjArray
      key = hintPipeObj["inPort"]

      if !!listMap[key]
        listMap[key]++
      else
        listMap[key] = 1


    key = hintPipeObjArray[i]["inPort"]    
    hintPipeObjWithNumber = listMap[key]

  renderHintsNetGraph: (hintPipeSet,searchKeyword) =>
    hintPipeSetJson = JSON.parse(hintPipeSet);
    numOfHintPipes = hintPipeSetJson.length;
    @$eml.find("#find_result").text("找到"+numOfHintPipes+"条思路")
    output = 'digraph "关于“' + searchKeyword + '”的思维引导图" { \n' +
      '  rankdir=TB\n' +
      '  graph [fontname="simhei" splines="polyline"]\n' +
      '  edge  [fontname="simhei" arrowsize="0.6"]\n' +
      '  node  [fontname="simhei" fontsize="9px" shape="note" height="0.1" style="filled" fillcolor="khaki1"] \n';
    for i in [0...numOfHintPipes]
      number =  @hintPipeAddNumber(hintPipeSetJson,i)
      color = @hintPipeAddColor(number)
      output +=
        '"' + hintPipeSetJson[i]["inPort"] + '"' + 
        '[color="' + color + '" fillcolor="' + color + '"]' + '\n' +
        '"' + hintPipeSetJson[i]["outPort"] + '"' +
        '[color="' + color + '"]' + '\n' +
        '"' + hintPipeSetJson[i]["inPort"] + '"' +
        " -> " +
        '"' + hintPipeSetJson[i]["outPort"] + '"' +
        '[label="..." labeltooltip="' + hintPipeSetJson[i]["purposeTags"] + '"]' +
        "\n";
    document.getElementById("hintPipes").innerHTML = output + '} ';
    console.log(output)
    @updateGraph();

  getAllThePortFromA2B: (A,B)=>
      $.ajax
        url: "/irregular_data_transforms/query_A_to_B",
        method: "post",
        data: {
          query_A : A,
          query_B : B
       }
      .success (msg) =>
        console.log(msg.result)
        @renderHintsNetGraph(msg.result,A)

  bind_event: ->
    @$eml.on "click", ".body .part-left .opml2graphviz",=>
      text_value = @$eml.find('.body .part-left textarea').val()
      xotree = new XML.ObjTree
      tree = xotree.parseXML(text_value)
      json_ary = tree["opml"]["body"]["outline"]["outline"]
      first_port = json_ary[0]["-text"]
      last_port = json_ary[json_ary.length-1]["-text"]
      @coupe_arys = []
      @make_coupe_arrays(json_ary)
      print_data = []
      for a in @coupe_arys
        print_data.push(
            '\n{\n' +
            ' "inPort" : "' + @replace_chars(a[0]) + '",\n' + 
            ' "outPort" : "' + @replace_chars(a[1]) + '",\n' +
            ' "tags" : "' + '#hint-pipe #to-refine' + '",\n' +
            ' "desc" : {  "title" : "简要说明", "content" : "..." },\n'+
            ' "infoUrl" : {  "title" : "参考链接", "href" : "..." }\n'+
            '}\n')

      console.log(print_data)
      $.ajax
        url: "/json_datas",
        method: "post",
        data: {save_json: "["+print_data+"]" }
      .success (msg) =>
       alert msg
       @getAllThePortFromA2B(first_port,last_port)

  
  
jQuery(document).on "ready page:load", ->
  if jQuery(".page-opml2graphviz").length > 0
    new Opml2graphviz jQuery(".page-opml2graphviz")
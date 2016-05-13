class Graphviz
  constructor: (@$eml) ->
    @bind_event()

  hintPipeIsEqual: (hintPipeA, hintPipeB)->
    if hintPipeA["inPort"] == hintPipeB["inPort"] && hintPipeA["outPort"] == hintPipeB["outPort"]
      return true
    else
      return false

  # 判断能否匹配到 #XXXXXX 形式的颜色值
  checkColorValue: (text)->
    getColorValue = "(#[0-9a-fA-F]{6})"
    regExpcheckColorValue = new RegExp(getColorValue, "g")
    checkColorValueResult = regExpcheckColorValue.exec(text)
    return checkColorValueResult

  # 把引思管道从字符串描述转换为 JS 对象
  hintPipeStr2Obj: (hintPipeStr)->
    regExpEn = "[a-zA-Z0-9]"
    regExpCJKIdeographs = "[㐀-\u4dbe一-\u9ffe]|[\ud840-\ud868\ud86a-\ud86c][\udc00-\udfff]|\ud869[\udc00-\udede\udf00-\udfff]|\ud86d[\udc00-\udf3e\udf40-\udfff]|\ud86e[\udc00-\udc1e]|[\ufa0e\ufa0f\ufa11\ufa13\ufa14\ufa1f\ufa21\ufa23\ufa24\ufa27-\ufa29]"
    regExpCJKSymbols = "[\u3000-〾？，、“”‘’（）《》—·]"
    portLabelPattern = regExpEn + "|" + regExpCJKIdeographs + "|" + regExpCJKSymbols
    hintPipePattern = "((" + portLabelPattern + ")+)" + "\\|->\\|" + "((" + portLabelPattern + ")+)?([^\\n]+|)"
    hintPipeObj = {}
    regExpForhintPipe = new RegExp(hintPipePattern, "g")
    regExpMatchResult = regExpForhintPipe.exec(hintPipeStr)
    
    checkColorValueResult = @checkColorValue(regExpMatchResult[0])
  
    if regExpMatchResult != null
      if checkColorValueResult == null
        hintPipeObj = {
          "inPort": regExpMatchResult[1],
          "outPort": regExpMatchResult[3],
          "completeString" : regExpMatchResult[0]
        }
      else
        hintPipeObj = {
          "inPort": regExpMatchResult[1],
          "outPort": regExpMatchResult[3],
          "color": checkColorValueResult[0],
          "completeString" : regExpMatchResult[0]
        }

    return hintPipeObj

  #添加颜色值,后续节点越多颜色越深
  hintPipeAddColor: (hintPipeObjWithNumber)->
    switch hintPipeObjWithNumber["number"]
      when 10 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#030387" + '\n'
      when 9 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#181891" + '\n'
      when 8 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#2D2D9B" + '\n'
      when 7 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#4242A5" + '\n'
      when 6 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#5757AF" + '\n'
      when 5 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#6C6CB9" + '\n'
      when 4 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#8181C3" + '\n'
      when 3 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#9696CD" + '\n'
      when 2 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#ABABD7" + '\n'
      when 1 then TextWithColor = '' +  hintPipeObjWithNumber["completeString"]  + ' ' + "#C0C0E1" + '\n'
    
    return TextWithColor
    
  # 为每条文本添加颜色值
  TextWithColors: (hintPipeObjWithNumberArray)->
    TextWithColors = ""
    for hintPipeObjWithNumber in hintPipeObjWithNumberArray
      TextWithColors += @hintPipeAddColor(hintPipeObjWithNumber)
    
    console.log(TextWithColors)
    return TextWithColors

  # 计算每个节点后续节点的数量,并将数量添加到json对象中
  hintPipeAddNumber: (hintPipeObjArray)->
    hintPipeObjWithNumberArray = []
    listMap = { }
    for hintPipeObj in hintPipeObjArray
      key = hintPipeObj["inPort"]

      if !!listMap[key]
        listMap[key]++
      else
        listMap[key] = 1

    for hintPipeObj in hintPipeObjArray
      key = hintPipeObj["inPort"]
      
      hintPipeObjWithNumber = {
        "inPort": hintPipeObj["inPort"]
        "outPort": hintPipeObj["outPort"]
        "completeString" : hintPipeObj["completeString"]
        "number": listMap[key]
      }

      hintPipeObjWithNumberArray.push(hintPipeObjWithNumber)

    return hintPipeObjWithNumberArray

  # 把引思管道大段文本的每个元素都从字符串描述转换为 JS 对象
  hintPipeText2ObjArray: (hintPipeText)->
    hintPipeStrArray = hintPipeText.split('\n')
    length = hintPipeStrArray.length
    hintPipeObjArray = []
    for hintPipeStr in hintPipeStrArray
      if hintPipeStr.trim() != " "
        hintPipeObjArray.push(@hintPipeStr2Obj(hintPipeStr.trim()))  
    return hintPipeObjArray
  
  # 把引思管道序列的每个元素都从 JS 对象转换为 Dot 语法描述字符串
  hintPipeObj2DotEdge: (hintPipeObj)->
    checkColorValueResult = @checkColorValue(hintPipeObj["color"])
    DotEdge = ""
    if hintPipeObj  != null
      if checkColorValueResult == null
        DotEdge = '  "' + hintPipeObj["inPort"] + '" -> "' + hintPipeObj["outPort"] + '"\n'
      else
        DotEdge = '  "' + hintPipeObj["inPort"] + '"[color="' + hintPipeObj["color"] + '" fillcolor="' + hintPipeObj["color"] + '"]' + '\n' +
        '  "' + hintPipeObj["inPort"] + '" -> "' + hintPipeObj["outPort"] + '" ' + '[color="' + hintPipeObj["color"] + '"]' + '\n'

    return DotEdge;

  # 把引思管道序列的每个元素都从 JS 对象转换为 Dot 语法描述字符串
  hintPipeObjArray2DotEdges: (hintPipeObjArray)->
    DotEdges = " "
    for hintPipeObj in hintPipeObjArray
      DotEdges += @hintPipeObj2DotEdge(hintPipeObj)
    
    return DotEdges

  # 为 Dot 语法描述字符串加上 digraph 的外包裹
  dotEdges2Digraph: (dotEdges, graphDir)->
    return 'digraph G {\n' +
    '  rankdir=' + graphDir + '\n' +
    '  graph [fontname="simhei" splines="polyline"]\n' +
    '  edge  [fontname="simhei" arrowsize="0.6"]\n' +
    '  node  [fontname="simhei" fontsize="9px" shape="note" height="0.1" style="filled" fillcolor="khaki1"]\n'+
    dotEdges +
    "}\n"

  
  # 把引思管道序列转换为横向 digraph
  hintPipes2DigraphLR: (hintPipeText)->
    hintPipeObjArray = @hintPipeText2ObjArray(hintPipeText)
    DotEdges = @hintPipeObjArray2DotEdges(hintPipeObjArray)
    digraphLR = @dotEdges2Digraph(DotEdges,"LR")
    return  digraphLR

  # 把引思管道序列转换为纵向 digraph
  hintPipes2DigraphLR: (hintPipeText)->
    hintPipeObjArray = @hintPipeText2ObjArray(hintPipeText)
    DotEdges = @hintPipeObjArray2DotEdges(hintPipeObjArray)
    digrapBT = @dotEdges2Digraph(DotEdges,"BT")
    return  digrapBT

  bind_event: ->
    @$eml.on "click", ".footer-button .text-to-graphviz",=>
      text_value = jQuery(".body .part-left textarea").val()
      final_dotEdges = @hintPipes2DigraphLR(text_value)
      jQuery(".body .part-right textarea").val(final_dotEdges)

    @$eml.on "click", ".footer-button .hintpipe-add-color",=>
      text_value = jQuery(".body .part-left textarea").val()
      hintPipeObjArray = @hintPipeText2ObjArray(text_value)
      hintPipeObjWithNumberArray = @hintPipeAddNumber(hintPipeObjArray)
      TextWithColors = @TextWithColors(hintPipeObjWithNumberArray)
      jQuery(".body .part-right textarea").val(TextWithColors)


jQuery(document).on "ready page:load", ->
  if jQuery(".text-graphviz").length > 0
    new Graphviz jQuery(".text-graphviz")
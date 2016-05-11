class Graphviz
  constructor: (@$eml) ->
    @bind_event()

  hintPipeIsEqual: (hintPipeA, hintPipeB)->
    if hintPipeA["inPort"] == hintPipeB["inPort"] && hintPipeA["outPort"] == hintPipeB["outPort"]
      return true
    else
      return false

  # 把引思管道从字符串描述转换为 JS 对象
  hintPipeStr2Obj: (hintPipeStr)->
    regExpEn = "[a-zA-Z0-9]"
    regExpCJKIdeographs = "[㐀-\u4dbe一-\u9ffe]|[\ud840-\ud868\ud86a-\ud86c][\udc00-\udfff]|\ud869[\udc00-\udede\udf00-\udfff]|\ud86d[\udc00-\udf3e\udf40-\udfff]|\ud86e[\udc00-\udc1e]|[\ufa0e\ufa0f\ufa11\ufa13\ufa14\ufa1f\ufa21\ufa23\ufa24\ufa27-\ufa29]"
    regExpCJKSymbols = "[\u3000-〾？，、“”‘’（）《》—·]"
    portLabelPattern = regExpEn + "|" + regExpCJKIdeographs + "|" + regExpCJKSymbols
    hintPipePattern = "((" + portLabelPattern + ")+)" + "\\|->\\|" + "((" + portLabelPattern + ")+)"
    hintPipeObj = {}
    regExpForhintPipe = new RegExp(hintPipePattern, "g")
    regExpMatchResult = regExpForhintPipe.exec(hintPipeStr)

    if regExpMatchResult != null
      hintPipeObj = {
        "inPort": regExpMatchResult[1],
        "outPort": regExpMatchResult[3]
      }
      
    return hintPipeObj

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
    DotEdge = ""
    if hintPipeObj  != null
      DotEdge = '  "' + hintPipeObj["inPort"] + '" -> "' + hintPipeObj["outPort"] + '"\n'
    
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


jQuery(document).on "ready page:load", ->
  if jQuery(".text-graphviz").length > 0
    new Graphviz jQuery(".text-graphviz")
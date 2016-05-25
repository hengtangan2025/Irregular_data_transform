class Xml2json
  constructor: (@$eml) ->
    @bind_event()
    @coupe_arys = []

  replace_chars: (text)->
    text1 = @replaceSpecialChar(text, '\\\\(?!n)(?!t)', '\\/')
    text2 = @replaceSpecialChar(text1, '\t', '  ')
    text3 = @replaceSpecialChar(text2, '\n', '\\n')
    text4 = @replaceSpecialChar(text3, '"', '\\"')
    text5 = @replaceSpecialChar(text4, '\'', '\\"')
    text6 = @replaceSpecialChar(text5, ':', '：')
    text7 = @replaceSpecialChar(text6, '，', ',')
    return text7

  replaceSpecialChar: (text, specialChar, safeChar)->
    patternInRegexp = new RegExp(specialChar, 'g')
    return text.replace(patternInRegexp, safeChar)

  bind_event: () ->
    @$eml.on "click", ".footer-button .xml-to-json",=>
      text_value = jQuery(".body .part-left textarea").val()
      xotree = new XML.ObjTree
      tree = xotree.parseXML(text_value)
      str_array = []
      jsonArray = tree["opml"]["body"]["outline"]["outline"]

      for json in jsonArray
        text = json["-text"]
        regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^#\\n]+) " + "([^\\n]+(?!#)|(?!@))"
        regExpForhintPipe = new RegExp(regExp, "g")
        regExpMatchResult = regExpForhintPipe.exec(text)
        if json["outline"]
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            ' "tags" : "' + regExpMatchResult[4] + '",\n' +
            ' "desc" : {  "title" : "' + @replace_chars(json["outline"][0]["-text"]) + '", "content" : "' + @replace_chars(json["outline"][0]["-_note"]) + '" } ,\n' +
            ' "infoUrl" : {  "title" : "' + @replace_chars(json["outline"][1]["-text"]) + '", "href" : "' + @replace_chars(json["outline"][1]["-_note"]) + '" } \n' +
            '}\n')
        else
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            ' "tags" : "' + regExpMatchResult[4] + '",\n' +
            '}\n')

           
      if str_array.length == 0
        text = jsonArray["-text"]
        regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^#@\\n]+)" + "([^\\n]+(?!#)|(?!@))"
        regExpForhintPipe = new RegExp(regExp, "g")
        regExpMatchResult = regExpForhintPipe.exec(text)
        if jsonArray["outline"]
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            ' "tags" : "' + regExpMatchResult[4] + '",\n' +
            ' "desc" : {  "title" : "' + @replace_chars(jsonArray["outline"][0]["-text"]) + '", "content" : "' + @replace_chars(jsonArray["outline"][0]["-_note"]) + '" } ,\n' +
            ' "infoUrl" : {  "title" : "' + @replace_chars(jsonArray["outline"][1]["-text"]) + '", "href" : "' + @replace_chars(jsonArray["outline"][1]["-_note"]) + '" } \n' +
            '}\n')
        else
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            ' "tags" : "' + regExpMatchResult[4] + '",\n' +
            '}\n')

      jQuery(".body .part-right textarea").val("["+str_array+"]")
      $.ajax
        url: "/json_datas",
        method: "post",
        data: {save_json: "["+str_array+"]" }
      .success (msg) =>
       alert msg

    # json2xml
    @$eml.on "click", ".footer-button .json-to-xml",=>
      text_value = jQuery(".body .part-left textarea").val()
      xotree = new XML.ObjTree
      json = eval("("+text_value+")")
      if json.length > 0
        data = '{'+'\n'+
          '"opml": {' +'\n'+
            '"-version": "2.0",' +'\n'+
            '"head": { "ownerEmail": "anonymous@hintsnet.com" },'+ '\n' +
            '"body": {'+'\n'+
              '"outline": {'+'\n'+
                '"-text": "workflowy格式数据样板",'+'\n'+
                '"outline": ['+'\n'+
                jQuery.map(json, (ary) -> 
                  return '{'+'\n'+'"-text": "'+ary["inPort"]+'|-&gt;|'+ary["outPort"]+'#hint-pipe #to-refine",'+'\n'+'"outline": ['+'\n'+'{'+'\n'+'"-text": "'+ary["desc"]["title"]+'",'+'\n'+'"-_note": "'+ary["desc"]["content"]+'"'+'\n'+'},'+'\n'+'{'+'\n'+'"-text": "'+ary["infoUrl"]["title"]+'",'+'\n'+'"-_note": "'+ary["infoUrl"]["href"]+'"'+'\n'+'}'+'\n'+']'+'\n'+'}'
                )+'\n'+
                ']'+'\n'+
              '}'+'\n'+
            '}'+'\n'+
          '}'+'\n'+
        '}'
      else
        data = '{'+'\n'+
          '"opml": {' +'\n'+
            '"-version": "2.0",' +'\n'+
            '"head": { "ownerEmail": "anonymous@hintsnet.com" },'+ '\n' +
            '"body": {'+'\n'+
              '"outline": {'+'\n'+
               '"-text": "workflowy格式数据样板",'+'\n'+
                '"outline": {'+'\n'+
                  '"-text": "'+json["inPort"]+'|-&gt;|'+json["outPort"]+'",'+'\n'+
                  '"outline": ['+'\n'+
                    '{'+'\n'+
                      '"-text": "'+json["desc"]["title"]+'",'+'\n'+
                      '"-_note": "'+json["desc"]["content"]+'"'+'\n'+
                    '},'+'\n'+
                    '{'+'\n'+
                      '"-text": "'+json["infoUrl"]["title"]+'",'+'\n'+
                      '"-_note": "'+json["infoUrl"]["href"]+'"'+'\n'+
                    '}'+'\n'+
                  ']'+'\n'+
                '}'+'\n'+
              '}'+'\n'+
            '}'+'\n'+
          '}'+'\n'+
        '}'

      json_datas = eval("("+data+")")
      jQuery(".body .part-right textarea").val(formatXml(xotree.writeXML(json_datas)))


    @$eml.on "click", ".footer-button .xml-to-json-a-b",=>
      text_value = jQuery(".body .part-left textarea").val()
      xotree = new XML.ObjTree
      tree = xotree.parseXML(text_value)
      json_ary = tree["opml"]["body"]["outline"]["outline"]
      @coupe_arys = []
      @make_coupe_arrays(json_ary)
      @coupe_arys.push(["...",json_ary[0]["-text"]])
      @coupe_arys.push([json_ary[json_ary.length-1]["-text"],"..."])
      print_data = []
      for a in @coupe_arys
        print_data.push(
            '\n{\n' +
            ' "inPort" : "' + a[0] + '",\n' + 
            ' "outPort" : "' + a[1] + '",\n' +
            ' "tags" : "' + '#hint-pipe #to-refine' + '",\n' +
            ' "desc" : {  "title" : "简要说明", "content" : "..." },\n'+
            ' "infoUrl" : {  "title" : "参考链接", "href" : "..." },\n'+
            '}\n')
      @$eml.find(".body .part-right textarea").val(print_data)

  
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





jQuery(document).on "ready page:load", ->
  if jQuery(".text-xml2json").length > 0
    new Xml2json jQuery(".text-xml2json")
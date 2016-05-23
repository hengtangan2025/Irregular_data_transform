class Xml2json
  constructor: (@$eml) ->
    @bind_event()

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
      # dumper = new JKL.Dumper()
      tree = xotree.parseXML(text_value)
      str_array = []
      jsonArray = tree["opml"]["body"]["outline"]["outline"]

      for json in jsonArray
        text = json["-text"]
        regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^#\\n]+)"
        regExpForhintPipe = new RegExp(regExp, "g")
        regExpMatchResult = regExpForhintPipe.exec(text)

        if json["outline"]
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            ' "desc" : {  "title" : "' + @replace_chars(json["outline"][0]["-text"]) + '", "content" : "' + @replace_chars(json["outline"][0]["-_note"]) + '" } ,\n' +
            ' "infoUrl" : {  "title" : "' + @replace_chars(json["outline"][1]["-text"]) + '", "href" : "' + @replace_chars(json["outline"][1]["-_note"]) + '" } \n' +
            '}\n')
        else
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            '}\n')

           
      if str_array.length == 0
        text = jsonArray["-text"]
        regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^#\\n]+)"
        regExpForhintPipe = new RegExp(regExp, "g")
        regExpMatchResult = regExpForhintPipe.exec(text)
        if jsonArray["outline"]
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
            ' "desc" : {  "title" : "' + @replace_chars(jsonArray["outline"][0]["-text"]) + '", "content" : "' + @replace_chars(jsonArray["outline"][0]["-_note"]) + '" } ,\n' +
            ' "infoUrl" : {  "title" : "' + @replace_chars(jsonArray["outline"][1]["-text"]) + '", "href" : "' + @replace_chars(jsonArray["outline"][1]["-_note"]) + '" } \n' +
            '}\n')
        else
          str_array.push(
            '\n{\n' +
            ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
            ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
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
      json_data = eval("("+data+")")
      jQuery(".body .part-right textarea").val(formatXml(xotree.writeXML(json_data)))


jQuery(document).on "ready page:load", ->
  if jQuery(".text-xml2json").length > 0
    new Xml2json jQuery(".text-xml2json")
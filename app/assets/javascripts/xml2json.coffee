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
    text7 = @replaceSpecialChar(text5, '，', ',')
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

        # descObj = {
        #   "title" : json["outline"][0]["-text"]
        #   "content" : json["outline"][0]["-_note"]
        # }

        # infoUrlObj = {
        #   "title" : json["outline"][1]["-text"]
        #   "href" : json["outline"][1]["-_note"]
        # }
      
        # jsonObj = {
        #   "inPort" : regExpMatchResult[1]
        #   "outPort" : regExpMatchResult[3]
        #   "desc" : descObj
        #   "infoUrl" : infoUrlObj
        # }

        str_array.push(
          '\n{\n' +
          ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
          ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
          ' "desc" : {  "title" : "' + @replace_chars(json["outline"][0]["-text"]) + '", "content" : "' + @replace_chars(json["outline"][0]["-_note"]) + '" } ,\n' +
          ' "infoUrl" : {  "title" : "' + @replace_chars(json["outline"][1]["-text"]) + '", "href" : "' + @replace_chars(json["outline"][1]["-_note"]) + '" } \n' +
          '}\n')

      if str_array.length == 0
        console.log(jsonArray["-text"])
        text = jsonArray["-text"]
        regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^#\\n]+)"
        regExpForhintPipe = new RegExp(regExp, "g")
        regExpMatchResult = regExpForhintPipe.exec(text)
        str_array.push(
          '\n{\n' +
          ' "inPort" : "' + regExpMatchResult[1] + '",\n' + 
          ' "outPort" : "' + regExpMatchResult[3] + '",\n' +
          ' "desc" : {  "title" : "' + @replace_chars(jsonArray["outline"][0]["-text"]) + '", "content" : "' + @replace_chars(jsonArray["outline"][0]["-_note"]) + '" } ,\n' +
          ' "infoUrl" : {  "title" : "' + @replace_chars(jsonArray["outline"][1]["-text"]) + '", "href" : "' + @replace_chars(jsonArray["outline"][1]["-_note"]) + '" } \n' +
          '}\n')

      jQuery(".body .part-right textarea").val("["+str_array+"]")

jQuery(document).on "ready page:load", ->
  if jQuery(".text-xml2json").length > 0
    new Xml2json jQuery(".text-xml2json")
class Xml2json
  constructor: (@$eml) ->
    @bind_event()

  bind_event: () ->
    @$eml.on "click", ".footer-button .xml-to-json",=>
      text_value = jQuery(".body .part-left textarea").val()
      xotree = new XML.ObjTree
      dumper = new JKL.Dumper()
      tree = xotree.parseXML(text_value)
      str_array = []
      # jsonObjArray = []
      jsonArray = tree["opml"]["body"]["outline"]["outline"]
      
      for json in jsonArray
        text = json["-text"]
        regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^\\n]+)"
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
          ' "inPort" : " ' + regExpMatchResult[1] + ' ",\n' + 
          ' "outPort" : " ' + regExpMatchResult[3] + ' ", \n' +
          ' "desc" : {  "title" : ' + json["outline"][0]["-text"] + ', "content" : ' + json["outline"][0]["-_note"] + ' } "  ,\n' +
          ' "infoUrl" : {  "title" : ' + json["outline"][1]["-text"] + ', "href" : ' + json["outline"][1]["-_note"] + ' } "  ,\n' +
          '}\n')

      
      jQuery(".body .part-right textarea").val("["+str_array+"]")

jQuery(document).on "ready page:load", ->
  if jQuery(".text-xml2json").length > 0
    new Xml2json jQuery(".text-xml2json")
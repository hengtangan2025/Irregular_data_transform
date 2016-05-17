class Xml2json
  constructor: (@$eml) ->
    @bind_event()

  bind_event: () ->
    @$eml.on "click", ".footer-button .xml-to-json",=>
      text_value = jQuery(".body .part-left textarea").val()
      xotree = new XML.ObjTree
      dumper = new JKL.Dumper()
      tree = xotree.parseXML(text_value)
      text = tree["opml"]["body"]["outline"]["outline"]["-text"]
      regExp = "([^\\|]+)" + "([^\\n]+(?=\\|))" + "\\|" + "([^\\n]+)"
      regExpForhintPipe = new RegExp(regExp, "g")
      regExpMatchResult = regExpForhintPipe.exec(text)
      descObj = {
        "title" : tree["opml"]["body"]["outline"]["outline"]["outline"][0]["-text"]
        "content" : tree["opml"]["body"]["outline"]["outline"]["outline"][0]["-_note"]
      }

      infoUrlObj = {
        "title" : tree["opml"]["body"]["outline"]["outline"]["outline"][1]["-text"]
        "href" : tree["opml"]["body"]["outline"]["outline"]["outline"][1]["-_note"]
      }
    
      jsonObj = {
        "inPort" : regExpMatchResult[1]
        "outPort" : regExpMatchResult[3]
        "desc" : descObj
        "infoUrl" : infoUrlObj
      }
      
      jQuery(".body .part-right textarea").val(dumper.dump(jsonObj))

jQuery(document).on "ready page:load", ->
  if jQuery(".text-xml2json").length > 0
    new Xml2json jQuery(".text-xml2json")
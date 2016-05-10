class Conversion
  constructor: (@$eml) ->
    @bind_event()

  replace_chars: (text)->
    console.log text

  bind_event: ->
    @$eml.on "click", ".footer-button .chinese-sequence-paren",=>
      text_value = jQuery(".body .part-left textarea").val()
      str_array = []
      regexp = new RegExp('^([ \\t]*（[一二三四五六七八九]）[^：\\r\\n]+)[：\\r\\n]+((?![^（）]*\\(\\))[^（）]*)', 'gm')
      while(result = regexp.exec(text_value))
        str_array.push('\n{\n'+'"说明文字的类别":"'+result[1]+'",\n'+'"说明文字":"\\n '+@replace_chars(result[2])+'\\n\\n"\n'+'}\n')
      jQuery(".body .part-right textarea").val("["+str_array+"]")


jQuery(document).on "ready page:load", ->
  if jQuery(".text-conversion").length > 0
    new Conversion jQuery(".text-conversion")

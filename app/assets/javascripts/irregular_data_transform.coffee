class Conversion
  constructor: (@$eml) ->
    @bind_event()

  replace_special_char: (text, char, safe)->
    patternInRegexp = new RegExp(char, 'g');
    return text.replace(patternInRegexp, safe)

  replace_chars: (text)->
    text1 = @replace_special_char(text, '\\\\(?!n)(?!t)', '\\/')
    text2 = @replace_special_char(text1, '\t', '  ')
    text3 = @replace_special_char(text2, '\n', '\\n')
    text4 = @replace_special_char(text3, '"', '\\"')
    text5 = @replace_special_char(text4, '\'', '\\"')
    text6 = @replace_special_char(text5, ':', '：')
    return text6

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

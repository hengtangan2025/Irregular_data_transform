class Conversion
  constructor: (@$eml) ->
    @bind_event()

  replace_chars: (text)->
    text1 = @replaceSpecialChar(text, '\\\\(?!n)(?!t)', '\\/')
    text2 = @replaceSpecialChar(text1, '\t', '  ')
    text3 = @replaceSpecialChar(text2, '\n', '\\n')
    text4 = @replaceSpecialChar(text3, '"', '\\"')
    text5 = @replaceSpecialChar(text4, '\'', '\\"')
    text6 = @replaceSpecialChar(text5, ':', '：')
    return text6

  textToStrArray: (text)->
    strArray = text.split('\n')
    map(strArray)
    return strArray

  strArrayIterator: (strArray, procFunc)->
    processedStrArray = [];
    idx for idx in [0..strArray.length-1](var idx = 0; idx < strArray.length; idx++) 
      trimmedStr = strArray[idx].trim()
      if (trimmedStr != "")
        processedStrArray.push(procFunc(trimmedStr))
      else 
    return processedStrArray;


  replaceSpecialChar: (text, specialChar, safeChar)->
    patternInRegexp = new RegExp(specialChar, 'g')
    return text.replace(patternInRegexp, safeChar)

  bind_event: ->
    @$eml.on "click", ".footer-button .chinese-sequence-paren",=>
      text_value = jQuery(".body .part-left textarea").val()
      str_array = []
      regexp = new RegExp('^([ \\t]*（[一二三四五六七八九]）[^：\\r\\n]+)[：\\r\\n]+((?![^（）]*\\(\\))[^（）]*)', 'gm')
      while(result = regexp.exec(text_value))
        str_array.push('\n{\n'+'"说明文字的类别":"'+result[1]+'",\n'+'"说明文字":"\\n '+@replace_chars(result[2])+'\\n\\n"\n'+'}\n')
      jQuery(".body .part-right textarea").val("["+str_array+"]")

    @$eml.on "click",".footer-button .figure-sequence",=>
      text_value = jQuery(".body .part-left textarea").val()
      text_value
      str_array = []
      regexp = new RegExp('^([ \\t]*[0-9]+、[^：]+)：([^]+?(?=[0-9]+、)|[^]+(?!1、)(?!2、)(?!3、)(?!4、)(?!5、)(?!6、)(?!7、)(?!8、)(?!9、)(?!10、))','gm')
      while(result = regexp.exec(text_value))
        str_array.push(
          '\n{\n' +
          ' "说明文字的类别" : " ' + result[1] + ' "  ,\n' + 
          ' "说明文字" : " \\n ' + @replace_chars(result[2]) + ' \\n\\n" \n' +
          '}\n')
       jQuery(".body .part-right textarea").val("["+str_array+"]")

jQuery(document).on "ready page:load", ->
  if jQuery(".text-conversion").length > 0
    new Conversion jQuery(".text-conversion")

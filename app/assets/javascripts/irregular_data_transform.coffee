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

  # 纯中文标题
  convertToUnixNewline: (text)->
    patternInRegexp = new RegExp('\r\n', 'g');
    return text.replace(patternInRegexp, '\n');

  appendNewlineTocolon: (text)->
    patternInRegexp = new RegExp('：', 'g');
    return text.replace(patternInRegexp, '：\n');

  replaceSpecialChar: (text, specialChar, safeChar)->
    patternInRegexp = new RegExp(specialChar, 'g');
    return text.replace(patternInRegexp, safeChar);

  replaceAllSpecialChars: (text)=>
    text1 = @replaceSpecialChar(text, '\\\\(?!n)(?!t)', '\\/');
    text2 = @replaceSpecialChar(text1, '\t', '  ');
    text3 = @replaceSpecialChar(text2, '\n', '\\n');
    text4 = @replaceSpecialChar(text3, '"', '\\"');
    text5 = @replaceSpecialChar(text4, '\'', '\\"');
    text6 = @replaceSpecialChar(text5, ':', '：');
    return text6;


  matchType03SubSections: (text)->
    patternInRegexp = new RegExp('^([ \\t]*[一二三四五六七八九十]+、[^：]+)：([^]+?(?=[一二三四五六七八九十]+、)|[^]+(?!一、)(?!二、)(?!三、)(?!四、)(?!五、)(?!六、)(?!七、)(?!八、)(?!九、)(?!十、))', 'gm');
    result;
    subSections = [];
    while(result = patternInRegexp.exec(text))
      subSections.push('{\n' +
      '"说明文字的类别": "' + @replaceAllSpecialChars(result[1]) + '",\n' +
      '"说明文字": "\\n    ' + @replaceAllSpecialChars(result[2]) + '\\n\\n" \n' +
      '}\n');
    return subSections;

  strArrayToJsonStr: (strArray)->
    generatedJsonStr = '';
    for idx in[0...strArray.length]
      generatedJsonStr += strArray[idx];
      if idx isnt strArray.length - 1 
        generatedJsonStr += ",\n";
    return '[\n' + generatedJsonStr + '\n]';
  # 


  bind_event: ->
    @$eml.on "click", ".footer-button .chinese-sequence-paren",=>
      text_value = jQuery(".body .part-left textarea").val()
      str_array = []
      regexp = new RegExp('^([ \\t]*（[一二三四五六七八九]）[^：\\r\\n]+)[：\\r\\n]+((?![^（）]*\\(\\))[^（）]*)', 'gm')
      while(result = regexp.exec(text_value))
        str_array.push('\n{\n'+'"说明文字的类别":"'+result[1]+'",\n'+'"说明文字":"\\n '+@replace_chars(result[2])+'\\n\\n"\n'+'}\n')
      jQuery(".body .part-right textarea").val("["+str_array+"]")

    # 纯中文标题
    @$eml.on "click", ".footer-button .chinese-sequence",=>
      text_value = jQuery(".body .part-left textarea").val()
      unixText = @convertToUnixNewline(text_value);
      colonWithNewlineText = @appendNewlineTocolon(unixText);
      processedStrArray = @matchType03SubSections(colonWithNewlineText);
      jQuery(".body .part-right textarea").val(@strArrayToJsonStr(processedStrArray))
    # 




jQuery(document).on "ready page:load", ->
  if jQuery(".text-conversion").length > 0
    new Conversion jQuery(".text-conversion")
class Conversion
  constructor: (@$eml) ->
    @bind_event()

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

  # 保存转换后的文件
  convert_sent_post: (fetch_text)->
    jQuery.ajax
      url: "/irregular_data_transforms/save_file_to_local",
      method: "post",
      data: {save_text: fetch_text }
    .success (msg) ->
      console.log "success"
    .error (msg) ->
      console.log "failure"
  #下载转换后的文件
  convert_sent_get: ()->
    location.href = "/irregular_data_transforms/down_load"

  # 获得输入的数据发post到后台进行格式转换
  conversion_to_RegExp: (text_value, chat_type_data)->
    jQuery.ajax
      url: "/irregular_data_transforms/convert",
      method: "post",
      data: {chat_text: text_value, chat_type: chat_type_data}
    .success (msg) ->
      jQuery(".body .part-right textarea").val(msg)
    .error (msg) ->
      console.log(msg)

  bind_event: ->
    # 带括号的中文标题
    @$eml.on "click", ".footer-button .chinese-sequence-paren",=>
      text_value = jQuery(".body .part-left textarea").val()
      str_array = []
      regexp = new RegExp('^([ \\t]*（[一二三四五六七八九]）[^：\\r\\n]+)[：\\r\\n]+((?![^（）]*\\(\\))[^（）]*)', 'gm')
      while(result = regexp.exec(text_value))
        str_array.push('\n{\n'+'"说明文字的类别":"'+@replaceAllSpecialChars(result[1])+'",\n'+'"说明文字":"\\n '+@replaceAllSpecialChars(result[2])+'\\n\\n"\n'+'}\n')
      jQuery(".body .part-right textarea").val("["+str_array+"]")


    # 纯中文标题
    @$eml.on "click", ".footer-button .chinese-sequence",=>
      text_value = jQuery(".body .part-left textarea").val()
      unixText = @convertToUnixNewline(text_value);
      colonWithNewlineText = @appendNewlineTocolon(unixText);
      processedStrArray = @matchType03SubSections(colonWithNewlineText);
      jQuery(".body .part-right textarea").val(@strArrayToJsonStr(processedStrArray))

    @$eml.on "click",".footer-button .figure-sequence",=>
      text_value = jQuery(".body .part-left textarea").val()
      str_array = []
      regexp = new RegExp('^([ \\t]*[0-9]+、[^：]+)：([^]+?(?=[0-9]+、)|[^]+(?!1、)(?!2、)(?!3、)(?!4、)(?!5、)(?!6、)(?!7、)(?!8、)(?!9、)(?!10、))','gm')
      while(result = regexp.exec(text_value))
        str_array.push(
          '\n{\n' +
          ' "说明文字的类别" : " ' + result[1] + ' "  ,\n' + 
          ' "说明文字" : " \\n ' + @replace_chars(result[2]) + ' \\n\\n" \n' +
          '}\n')
       jQuery(".body .part-right textarea").val("["+str_array+"]")

    # QQ聊天纪录转换成YMAL
    @$eml.on "click", ".footer-button .chatflow-qq", ->
      chat_type_data = jQuery(this).closest(".chatflow-qq").attr("data-chat-type")
      text_value = jQuery(".body .part-left textarea").val()
      @conversion_to_RegExp(text_value, chat_type_data)

    # 微信聊天纪录转换成YAML
    @$eml.on "click", ".footer-button .chatflow-wechat", ->
      chat_type_data = jQuery(this).closest(".chatflow-wechat").attr("data-chat-type")
      text_value = jQuery(".body .part-left textarea").val()
      @conversion_to_RegExp(text_value, chat_type_data)

    #保存yaml文件并下载
    @$eml.on "click", ".body .save-script .save-file", =>
      fetch_text = jQuery(".body .part-right textarea").val()
      @convert_sent_post(fetch_text)
      @convert_sent_get()

jQuery(document).on "ready page:load", ->
  if jQuery(".text-conversion").length > 0
    new Conversion jQuery(".text-conversion")

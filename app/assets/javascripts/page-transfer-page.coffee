jQuery(document).on "ready page:load", ->
  if jQuery(".page-transfer-page").length > 0
    $(document)
      .on "dragleave", (e)->
        e.preventDefault()
      .on "drop", (e)->
        e.preventDefault()
      .on "dragenter", (e)->
        e.preventDefault()
      .on "dragover", (e)->
        e.preventDefault()
 
    box = document.getElementById('upload-div')
    box.addEventListener "drop",(e)->
      e.preventDefault(); 
      fileList = e.dataTransfer.files;

      xhr = new XMLHttpRequest();
      xhr.open("post", "/transfer_action", false);
      xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      fd = new FormData();
      fd.append('transfer_file', fileList[0]);
      xhr.send(fd);
      $fill_blank = $(document).find('.transformed_graphml_blank')
      $fill_blank.val("")
      $fill_blank.val(xhr.responseXML.getElementsByTagName("strs")[0].childNodes[0].nodeValue)
    , false

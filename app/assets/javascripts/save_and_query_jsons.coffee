class SaveAndQueryJsons
  constructor: (@$eml) ->
    @bind_event()

  bind_event: ->
    @$eml.on "click", ".save-json-btn",=>
      save_json_value = @$eml.find('.save_json_blank').val()
      $.ajax
        url: "/json_datas",
        method: "post",
        data: {save_json: save_json_value }
      .success (msg) =>
       alert msg

    @$eml.on "click", ".query-json-btn",=>
      query_json_value = @$eml.find('.query_blank').val()
      $.ajax
        url: "/irregular_data_transforms/query_json",
        method: "post",
        data: {query_json: query_json_value }
      .success (msg) =>
       @$eml.find(".query_blank_results").val(msg.result)
         

jQuery(document).on "ready page:load", ->
  if jQuery(".page-save-and-query-jsons").length > 0
    new SaveAndQueryJsons jQuery(".page-save-and-query-jsons")
class GraphvizTOGML
  constructor: (@$eml) ->
    @bind_event()

  bind_event: ->
    @$eml.on "click", ".footer-button .text-to-graphviz",=>
      text_value = @$eml.find('.body .part-left textarea').val()
      $.ajax
        url: "/irregular_data_transforms/graphviz_to_gml_progarm",
        method: "post",
        data: {graphviz: text_value }
      .success (msg) =>
        @$eml.find(".body .part-right textarea").val(msg)
         

jQuery(document).on "ready page:load", ->
  if jQuery(".graphviz-to-gml").length > 0
    new GraphvizTOGML jQuery(".graphviz-to-gml")
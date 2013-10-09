root = exports ? this

$ ->

  initWeightSlider = () ->

    $(".weight-slider").on "change", (event) ->
      metric = $(this).data("metric")
      value = $(this).val()
      $(this).parents("td").find("span").html("#{value}&times;")

  if isPath("/repositories/#{repositoryId}/snapshots/#{snapshotId}")
    initWeightSlider()

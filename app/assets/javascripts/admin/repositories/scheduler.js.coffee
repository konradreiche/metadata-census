root = exports ? this

$ ->

  initMetricJobButtons = () ->
    repository = gon.repository.name
    $(".schedule-metric-job").on "click", initJobCallback()

  initJobCallback = () ->
    return (event) ->
      button = $(event.target)
      button.attr("disabled", "disabled")

  id = gon.repository.id
  if root.isPath("/admin/repositories/:repository_id/scheduler", id)
    initMetricJobButtons()


root = exports ? this

$ ->

  initMetricJobButtons = () ->
    repository = gon.repository.name
    $(".schedule-metric-job").on "click", initJobCallback()

  initJobCallback = () ->
    return (event) ->
      button = $(event.target)
      button.attr("disabled", "disabled")

  if root.isPath("/admin/repositories/:id/scheduler", root.repositoryRegExp, gon.repository.id)
    initMetricJobButtons()


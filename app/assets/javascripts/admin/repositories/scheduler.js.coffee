root = exports ? this

$ ->

  hideStatusLabels = () ->
    $(".label").hide()

  showStatusLabel = (metric) ->
    $("##{metric}.label").show()

  initScheduleJobButtons = () ->
    repository = gon.repository.name
    $(".schedule-job").on "click", createScheduleJobCallback()

  createScheduleJobCallback = () ->
    return (event) ->
      button = $(event.target)
      metric = button.data("metric")
      button.attr("disabled", "disabled")
      showStatusLabel(metric)

  id = gon.repository.id
  if root.isPath("/admin/repositories/:repository_id/scheduler", id)
    hideStatusLabels()
    initScheduleJobButtons()

root = exports ? this

$ ->

  hideStatusLabels = () ->
    $(".label.label-info").hide()

  showStatusLabel = (metric) ->
    $("##{metric}.label.label-info").show()

  initScheduleJobButtons = () ->
    $(".schedule-job").on "click", createScheduleJobCallback()

  createScheduleJobCallback = () ->
    return (event) ->
      button = $(event.target)
      repository = gon.repository.id
      metric = button.data("metric")

      button.attr("disabled", "disabled")
      showStatusLabel(metric)

      url = "/admin/repositories/#{repository}/metrics/#{metric}/schedule"
      $.post(url, (data, status) -> startRequestStatusLoop())

  startRequestStatusLoop = () ->
    $.getJSON("/admin/scheduler/status", processStatus)

  processStatus = (response) ->
    for repository, metric of response
      for metric, job of metric
        updateJobProgress(repository, metric, job)

  updateJobProgress = (repository, metric, job) ->
    null

  id = gon.repository.id
  if root.isPath("/admin/repositories/:repository_id/scheduler", id)
    hideStatusLabels()
    initScheduleJobButtons()

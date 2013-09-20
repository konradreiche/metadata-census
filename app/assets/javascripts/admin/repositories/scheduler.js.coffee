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
      $.post(url, (data, status) -> requestStatusLoop())

  requestStatusLoop = () ->
    repository = gon.repository.id
    $.getJSON("/admin/repositories/#{repository}/status", processStatus)

  processStatus = (response) ->
    for metric, job of response
      updateProgressBar(metric, job.state, job.percent)
      if job.state == "compute"
        updateProgressBar(metric, "analyze", 100)

    if not finished(response)
      setTimeout(requestStatusLoop, 500)

  updateProgressBar = (metric, state, percent) ->
    barElement = $(".progress-bar.#{metric}.#{state}")
    barElement.css("width", "#{percent}%")

  finished = (response) ->
    for metric, status in response
      if job.status in ["queued", "working"]
        return false

    return true

  id = gon.repository.id
  if root.isPath("/admin/repositories/:repository_id/scheduler", id)
    hideStatusLabels()
    initScheduleJobButtons()
    requestStatusLoop()

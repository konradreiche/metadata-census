root = exports ? this

$ ->

  COMPUTE = "compute"
  ANALYZE = "analyze"

  COMPLETE = "complete"
  FAILED = "failed"

  ###
  Hide all labels which are in fact status labels.
  ###
  hideStatusLabels = () ->
    $(".label").hide()

  showStatusLabel = (metric, which) ->
    $("##{metric}.label").hide()

    labelClass =
      computing: "label-info"
      finished:  "label-success"
      failed:    "label-danger"

    $("##{metric}.label.#{labelClass[which]}").show()

  disableButton = (metric, disable) ->
    $(".schedule-job.#{metric}").prop("disabled", disable)

  initScheduleJobButtons = () ->
    $(".schedule-job").on "click", createScheduleJobCallback()

  createScheduleJobCallback = () ->
    return (event) ->
      button = $(event.target)
      repository = gon.repository.id
      metric = button.data("metric")

      disableButton(metric, true)
      resetProgressBar(metric)

      url = "/admin/repositories/#{repository}/metrics/#{metric}/schedule"
      $.post(url, requestStatusLoop)

  ###
  Retrieves the job status and updates the interface. The request status loop
  is repeated until all jobs of this repository are finished.
  ###
  requestStatusLoop = () ->
    id = gon.repository.id
    $.getJSON("/admin/repositories/#{id}/status", processStatus)

  ###
  Iterates the status objects and updates the interface accordingly.
  ###
  processStatus = (response) ->
    
    for metric, job of response
      fillProgressBar(metric, job.state, job.percent)
      disableButton(metric, true)

      console.log job
      # If job is in state compute, analyze is finished
      if job.state == COMPUTE
        fillProgressBar(metric, ANALYZE, 100)
      
      if job.status == FAILED
        showStatusLabel(metric, "failed")

    if not finished(response)
      setTimeout(requestStatusLoop, 500)
    else
      displayCompletions(response)

  ###
  Fills a certain progress bar to the given percentage.
  ###
  fillProgressBar = (metric, state, percent) ->
    barElement = $(".progress-bar.#{metric}.#{state}")
    barElement.css("width", "#{percent}%")

  ###
  Updates the interface to reflect the completion of all jobs.
  ###
  displayCompletions = (response) ->
    for metric, job of response
      if job.status != FAILED
        fillProgressBar(metric, ANALYZE, 100)
        fillProgressBar(metric, COMPUTE, 100)
        showStatusLabel(metric, "finished")
        disableButton(metric, false)

  ###
  Sets the progress bars of a certain metric back to 0%.
  ###
  resetProgressBar = (metric) ->
    fillProgressBar(metric, ANALYZE, 0)
    fillProgressBar(metric, COMPUTE, 0)

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

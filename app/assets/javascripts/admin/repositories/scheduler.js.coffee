root = exports ? this

$ ->

  # Job Stages
  LOAD    = "load"
  ANALYZE = "analyze"
  COMPUTE = "compute"
  
  # Job Status
  QUEUED   = "queued"
  WORKING  = "working"
  COMPLETE = "complete"
  FAILED   = "failed"

  # Maps the job status to the status label class.
  STATUS_LABEL_CLASS =
    queued:    "label-info",
    working:   "label-info",
    complete:  "label-success",
    failed:    "label-danger"

  ###
  Initialize the interface to the default state.
  Hide labels and add event to the buttons.
  ###
  initInterface = () ->
    $(".label").hide()
    $(".schedule-job").on "click", scheduleJob

  ###
  Updates the interface according to the job information.
  ###
  updateInterface = () ->
    id = gon.repository.id
    $.getJSON("/admin/repositories/#{id}/status", updateElements)

  ###
  Updates all the interface element according to the response.
  ###
  updateElements = (response) ->
    for metric, job of response
      fillProgressBar(metric, job.stage, job.percent)
      displayStatusLabel(metric, job.status)
      setButtonState(metric, job.status)

  ###
  Fills a certain progress bar to the given percentage.
  ###
  fillProgressBar = (metric, stage, percent) ->

    # In stage compute, analyze is already finished
    if stage == COMPUTE
      fillProgressBar(metric, ANALYZE, 100)

    barElement = $(".progress-bar.#{metric}.#{stage}")
    barElement.css("width", "#{percent}%")

  ###
  Displays the status label corresponding to the job stage.
  ###
  displayStatusLabel = (metric, status) ->
    labelClass = STATUS_LABEL_CLASS[status]
    $("##{metric}.label").hide()
    $("##{metric}.label.#{labelClass}").show()


  ###
  Either enables or disables the button based on the job status.
  ###
  setButtonState = (metric, status) ->
    button = $(".schedule-job.#{metric}")

    if status in ["queued", "working"]
      button.prop("disabled", true)
    else
      button.prop("disabled", false)

  ###
  Schedules a new job to compute the metric for the current repository.
  ###
  scheduleJob = (event) ->
    button = $(event.target)
    id = gon.repository.id
    metric = button.data("metric")

    disableButton(metric, true)
    resetProgressBar(metric)

    url = "/admin/repositories/#{id}/metrics/#{metric}/schedule"
    $.post(url, requestStatusLoop)

  disableButton = (metric, disable) ->
    $(".schedule-job.#{metric}").prop("disabled", disable)

  createScheduleJobCallback = () ->

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
      fillProgressBar(metric, job.stage, job.percent)
      disableButton(metric, true)

      console.log job
      # If job is in the compute stage, analyze is finished
      if job.stage == COMPUTE
        fillProgressBar(metric, ANALYZE, 100)
      
      if job.status == FAILED
        showStatusLabel(metric, "failed")

    if not finished(response)
      setTimeout(requestStatusLoop, 500)
    else
      displayCompletions(response)

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
    initInterface()
    updateInterface()

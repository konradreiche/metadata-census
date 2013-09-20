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
      updateProgressBar(metric, job.stage, job.percent)
      updateStatusLabel(metric, job.status)
      updateButtons(metric, job.status)

  ###
  Fills a certain progress bar to the given percentage.
  ###
  updateProgressBar = (metric, stage, percent) ->

    # In stage compute, analyze is already finished
    if stage == COMPUTE
      updateProgressBar(metric, ANALYZE, 100)

    barElement = $(".progress-bar.#{metric}.#{stage}")
    barElement.css("width", "#{percent}%")

  ###
  Displays the status label corresponding to the job stage.
  ###
  updateStatusLabel = (metric, status) ->
    labelClass = STATUS_LABEL_CLASS[status]
    $("##{metric}.label").hide()
    $("##{metric}.label.#{labelClass}").show()

  ###
  Either enables or disables the button based on the job status.
  ###
  updateButtons = (metric, status) ->
    button = $(".schedule-job.#{metric}")

    if status in ["queued", "working"]
      button.prop("disabled", true)
    else
      button.prop("disabled", false)

  ###
  Resets the job status of the given metric back to zero progress.
  ###
  resetStatus = (metric) ->
    $("##{metric}.label").hide()
    $(".schedule-job.#{metric}").prop("disabled", true)
    $(".progress-bar.#{metric}.#{ANALYZE}").css("width", "0%")
    $(".progress-bar.#{metric}.#{COMPUTE}").css("width", "0%")

  ###
  Schedules a new job to compute the metric for the current repository.
  ###
  scheduleJob = (event) ->
    id = gon.repository.id
    button = $(event.target)
    metric = button.data("metric")

    url = "/admin/repositories/#{id}/metrics/#{metric}/schedule"
    $.post url, statusLoop(metric)

  ###
  Starts the status loop.
  ###
  statusLoop = (metric) ->
    return () =>

      resetStatus(metric)
      $.getJSON "/admin/repositories/#{id}/status", (response) ->
        updateElements(response)

        if not finished(response)
          setTimeout(statusLoop(metric), 500)
        else
          updateElements(response)
          updateDateTime(metric)

  ###
  Checks the current status to see if all jobs have terminated.
  ###
  finished = (response) ->
    for metric, job of response
      if job.status in ["queued", "working"]
        return false

    return true

  ###
  Fetches and dispalys the last updated date and time of the metric.
  ###
  updateDateTime = (metric) ->
    url = "/admin/repositories/#{id}/metrics/#{metric}/last_updated"
    $.getJSON url, (response) ->
      dateCell = $(".status.#{metric} .date")
      timeCell = $(".status.#{metric}").next("tr").children(".time")
      if timeCell.exists()
        dateCell.text(response.date)
        timeCell.text(response.time)
      else
        dateCell.text(response.date)
        dateCell.removeAttr("rowspan")
        timeCell = $("<td>#{response.time}</td>")
        timeCell.addClass("time")
        $(".status.#{metric}").next("tr").append(timeCell)


  id = gon.repository.id
  if root.isPath("/admin/repositories/:repository_id/scheduler", id)
    initInterface()
    updateInterface()

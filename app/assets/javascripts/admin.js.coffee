#=require spin.min
#=require jquery.spin
$ ->

  # Adds to each compute button a callback event
  initializeButtons = () ->
    repository = gon.repository.name
    $(".compute-metric.all").click(
      createComputeMetricCallback(repository, '*'))
    for metric in gon.metrics
      $(".compute-metric.#{metric}").click(
        createComputeMetricCallback(repository, metric))

  # Create the callback used for the metric button click handler
  createComputeMetricCallback = (repository, metric) ->
    return () ->
      disableButton(repository, metric)
      showSpinner(metric)
      parameter = {'repository': repository, 'metric': metric}
      $.post('/metrics/compute', parameter, (data, status) => requestStatus())

  # Enables the button
  enableButton = (repository, metric) ->
    changeButtonState(repository, metric, false)

  # Disables the button
  disableButton = (repository, metric) ->
    changeButtonState(repository, metric, true)

  # Adds a spinning wheel to the status table cell
  showSpinner = (metric) ->
    optitons =
      lines: 10
      length: 1
    if metric == '*'
      target = $(".admin.control > .admin.control.status")
    else
      target = $(".admin.control.#{metric} > .admin.control.status")
    target.spin(optitons)

  # Removes the spinning wheel from the status table cell
  hideSpinner = (metric) ->
    target = $(".admin.control.#{metric} > .admin.control.status")
    target.spin(false)

  # Change button state based on the boolean disable
  changeButtonState = (repository, metric, disable) ->
    repositoryId = repository.split('.').join('-')

    if metric == '*'
      button = $(".btn.compute-metric.all")
    else
      button = $(".btn.compute-metric.#{repositoryId}.#{metric}")

    if disable
      button.attr('disabled', 'disabled')
    else
      button.removeAttr('disabled')
    
  # Request the status of issued jobs
  requestStatus = () ->
    $.getJSON('/metrics/status', processStatus)

  # Processes the JSON-encoded job progress results
  jobs = sum = 0
  processStatus = (response) ->
    for repository, metrics of response
      for metric, job of metrics
        displayJobProgress(repository, metric, job)
        sum += job.percent
        jobs += 1

    fillOverallProgressBar(sum / jobs)
    if repeatRequest(response)
      setTimeout(requestStatus, 500)

  # Visualizes the job progresses
  displayJobProgress = (repository, metric, job) ->
    type = determineBarType(job)
    if type?
      fillProgressBar(repository, metric, type, job.percent)
      if type == 'compute'
        fillProgressBar(repository, metric, 'analyze', '100%')

    if job.status == 'complete'
      enableButton(repository, metric)
      hideSpinner(metric)
    else
      disableButton(repository, metric)
      showSpinner(metric)

  # Determines progress bar element that need change based on the
  # current job state
  determineBarType = (job) ->
    type = null
    types = ['analyze', 'compute']
    if job.state? and job.state in types
      type = job.state
    return type

  fillOverallProgressBar = (percent) ->
    barDiv = $(".admin.control.progress > .all.progress-bar")
    barDiv.css('width', "#{percent}%")

  # Fills a defined progress bar up to the given percent
  fillProgressBar = (repository, metric, type, percent) ->
    progressClass = '.admin.control.progress'
    repositoryId = repository.split('.').join('-')
    barDiv = $("#{progressClass} .#{repositoryId}.#{metric}.#{type}.progress-bar")
    barDiv.css('width', "#{percent}%")

  # Determines whether the request for the job progress should
  # be repeated
  repeatRequest = (response) ->
    for repository, metrics of response
      for metric, job of metrics
        if job.status == 'queued' or job.status == 'working'
          return true
    return false

  if gon? and gon.repository? and gon.metrics?
    # activate repository selector
    $('.dropdown-toggle').dropdown()
    initializeButtons()
    requestStatus()

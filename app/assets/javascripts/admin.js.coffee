$ ->

  # Adds to each compute button a callback event
  initializeButtons = () ->
    for metric in gon.metrics
      repository = gon.repository.name
      $(".compute-metric.#{metric}").click createRequestCallback(repository, metric)

  # Create the callback used for the metric button click handler
  createRequestCallback = (repository, metric) ->
    return () ->
      parameter = {'repository': repository, 'metric': metric}
      $.post('/metrics/compute', parameter, (data, status) =>
        requestStatus()
      )

  # Request the status of issued jobs
  requestStatus = () ->
    $.getJSON('/metrics/status', processStatus)

  # Processes the JSON-encoded job progress results
  processStatus = (response) ->
    for repository, metrics of response
      for metric, job of metrics
        displayJobProgress(repository, metric, job)

    if repeatRequest(response)
      setTimeout(requestStatus, 500)

  # Visualizes the job progresses
  displayJobProgress = (repository, metric, job) ->
    type = determineBarType(job)
    if type?
      fillProgressBar(repository, metric, type, job.percent)
      if type == 'compute'
        fillProgressBar(repository, metric, 'analyze', '100%')

  # Determines progress bar element that need change based on the
  # current job state
  determineBarType = (job) ->
    type = null
    types = ['analyze', 'compute']
    if job.state? and job.state in types
      type = job.state
    return type

  # Fills a defined progress bar up to the given percent
  fillProgressBar = (repository, metric, type, percent) ->
    progressClass = '.admin.control.progress'
    repositoryId = repository.split('.').join('-')
    barDiv = $("#{progressClass} .#{repositoryId}.#{metric}.#{type}.bar")
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

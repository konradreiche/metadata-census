$ ->

  # Create the callback used for the metric button click handler
  createRequestCallback = (repository, metric) ->
    return () ->
      parameter = {'repository': repository, 'metric': metric}
      $.post('/metrics/compute', parameter, (data, status) =>
        requestStatus()
      )

  requestStatus = () ->
    $.getJSON('/metrics/status', processStatus)

  processStatus = (response) ->
    for repository, metrics of response
      for metric, job of metrics
        type = determineBarType(job)
        if type?
          progressClass = '.admin.control.progress'
          repositoryId = repository.split('.').join('-')
          barDiv = $("#{progressClass} .#{repositoryId}.#{metric}.#{type}.bar")
          barDiv.css('width', "#{job.percent}%")
          if type == 'compute'
            barDiv = $("#{progressClass} .#{repositoryId}.#{metric}.analyze.bar")
            barDiv.css('width', "100%")


    if repeatRequest(response)
      setTimeout(requestStatus, 500)

  determineBarType = (job) ->
    type = null
    types = ['analyze', 'compute']
    if job.state? and job.state in types
      type = job.state
    return type

  repeatRequest = (response) ->
    for repository, metrics of response
      for metric, job of metrics
        if job.status == 'queued' or job.status == 'working'
          return true
    return false

  initializeButtons = () ->
    for metric in gon.metrics
      repository = gon.repository.name
      $(".compute-metric.#{metric}").click createRequestCallback(repository, metric)

  if gon? and gon.repository? and gon.metrics?

    # activate repository selector
    $('.dropdown-toggle').dropdown()
    initializeButtons()
    requestStatus()

$ ->

  # Create the callback used for the metric button click handler
  createRequestCallback = (repository, metric) ->
    return () ->
      parameter = {"repository": repository, "metric": metric}
      $.post("/metrics/compute", parameter, (data, status) =>
        requestStatus()
      )

  requestStatus = () ->
    $.getJSON('/metrics/status', processStatus)

  processStatus = (response) ->
    for repository, metrics of response
      for metric, status of metrics
        progressClass = "admin.control.progress"
        barDiv = $("#{progressClass} #{repository}.#{metric}.bar")
        barDiv.css("width", status.percent)

  initializeButtons = () ->

    for metric in gon.metrics
      repository = gon.repository.name
      $(".compute-metric.#{metric}").click createRequestCallback(repository, metric)

  if gon? and gon.repository? and gon.metrics?

    # activate repository selector
    $('.dropdown-toggle').dropdown()
    initializeButtons()



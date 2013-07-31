$ ->

  createRequestCallback = (repository, metric) ->
    return () ->
      parameter = {"repository": repository, "metric": metric}
      $.post("/metrics/compute", parameter)

  initializeButtons = () ->

    for metric in gon.metrics
      repository = gon.repository.name
      $(".compute-metric.#{metric}").bind 'click', createRequestCallback(repository, metric)

  if gon? and gon.repository? and gon.metrics?

    # activate repository selector
    $('.dropdown-toggle').dropdown()
    initializeButtons()



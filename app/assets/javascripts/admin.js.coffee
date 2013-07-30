$ ->

  initializeButtons = () ->

    for metric in gon.metrics
      repository = gon.repository.name
      $(".compute-metric.#{metric}").on 'click', (event) =>
        parameter = { "repository": repository, "metric": metric }
        $.post("/metrics/compute", parameter, (data, status) =>
          console.log data
        )

  if gon? and gon.repository? and gon.metrics?

    # activate repository selector
    $('.dropdown-toggle').dropdown()
    initializeButtons()



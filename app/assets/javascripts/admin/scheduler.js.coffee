root = exports ? this

$ ->

  initMetricJobButtons = () ->
    repository = gon.repository.name
    $(".schedule-metric-job").on "click", initJobCallback(event)

  initJobCallback = (event) ->
    return () =>
      button = $(this)
      button.attr('disabled', 'disabled')
      # send post request


  if root.isPath("/admin/scheduler")
   initMetricJobButtons()


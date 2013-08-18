#=require d3
#=require bootstrap-rowlink.min
$ ->

  # Metric abbreviation are used in the result table
  createMetricAbbreviation = (metric) ->
    abbreviation = ''
    for word in metric.split('_')
      abbreviation += word[0].toUpperCase()
    return abbreviation

  # Create one result row for the result table
  createTableRow = (metadata, i) ->
    record = metadata.id
    url = createReportLink(record, i)
    tdId = "<td><a href=\"#{url}\">#{metadata.record.id}</a></td>"
    tdName = "<td>#{metadata.record.name}</td>"

    tdScores = ""
    for metric in gon.metrics
      if metadata[metric]?
        tdScore = "<td>#{metadata[metric].toFixed(2)}</td>"
      else
        tdScore = "<td>N/A</td>"
      tdScores += tdScore

    return "<tr class='rowlink'>#{tdId}#{tdName}#{tdScores}</tr>"

  # Create the URLs used in the result table
  createReportLink = (record, i) ->

    metric = metric_url_representation(gon.metric)
    repository = gon.repository.name

    parameters =
      show: metric
      repository: repository

    parameters["record#{i}"] = record

    record_numbers = [1..2]
    index = $.inArray(i, record_numbers)
    record_numbers.splice(index, 1)

    for j in record_numbers
      parameters["record#{j}"] = gon["record#{j}"].id

    url = "/report/metric?" + $.param(parameters)
    return url

  metric_url_representation = (metric) ->
    return metric.split('_').join('-')

  # Callback function for querying the metadata records
  displayRecordResults = (result) ->
    which_record = $("#search-input").data("record")
    if result.length > 0
      for metadata in result
        row = createTableRow(metadata, which_record)
        $("#search-results > tbody").append(row)
    else
      $("#search-results").hide()

  # Initializer function to set up the page
  initialize = () ->

    $(".dropdown-toggle").dropdown()
    $(".search.report.row").hide()
    $(".nav.nav-tabs a").on 'click', (event) =>
      event.preventDefault()
      $(event.target).tab("show")

    $(".report.repository-select").on 'change', (event) =>
      repository = $(".report.repository-select").val()
      window.location = "repository?show=#{repository}"

    $("a.report.search").on 'click', (event) =>
      record = $(event.target).data('record')
      $(".search.report.row").show()
      $("#search-input").data('record', record)
      $("#search-results").hide()

    $("#search-input").on 'input', (event) =>
      $("#search-results tbody").empty()
      $("#search-results").show()

      query = $("#search-input").val()
      query = if /\S/.test(query) then query else '*'
      repository = gon.repository.name

      data =
        q: query
        repository: repository

      $.getJSON("/metadata/search", data, displayRecordResults)

  initialize()

#=require d3
$ ->

  createMetricAbbreviation = (metric) ->
    abbreviation = ''
    for word in metric.split('_')
      abbreviation += word[0].toUpperCase()
    return abbreviation

  displayRecordResults = (result) ->

    if result.length > 0

      for metadata in result
        id = "<td>#{metadata.record.id}</td>"
        name = "<td>#{metadata.record.name}</td>"
        scores = ''

        for metric in gon.metrics
          if metadata[metric]?
            score = "<td>#{metadata[metric].toFixed(2)}</td>"
          else
            score = '<td>N/A</td>'
          scores += score
        row = "<tr>#{id}#{name}#{scores}</tr>"

        $("#search-results>tbody").append(row)
    else
      $("#search-results").hide()

  $(".search.report.row").hide()

  $(".report.repository-select").on 'change', (event) =>
    repository = $(".report.repository-select").val()
    window.location = "repository?show=#{repository}"

  $(".dropdown-toggle").dropdown()

  $("a.report.search").on 'click', (event) =>
    parameter = $(event.target).data('parameter')
    $(".search.report.row").show()
    $("#search-results").hide()

  $("#search-input").on 'input', (event) =>
    $("#search-results tbody").empty()
    query = $("#search-input").val()
    query = if /\S/.test(query) then query else '*'
      
    $("#search-results").show()
    $.getJSON("/metadata/search?q=#{query}", displayRecordResults)

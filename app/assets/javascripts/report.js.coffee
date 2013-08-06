#=require d3
$ ->

  $(".search.report.row").toggle()

  $(".report.repository-select").on 'change', (event) =>
    repository = $(".report.repository-select").val()
    window.location = "repository?show=#{repository}"

  $(".dropdown-toggle").dropdown()

  $("a.report.search").on 'click', (event) =>
    parameter = $(event.target).data('parameter')
    $(".search.report.row").toggle()
    $("#search-results").toggle()

  $("#search-input").on 'input', (event) =>
    $("#search-results tbody").empty()
    query = $("#search-input").val()
    query = if /\S/.test(query) then query else '*'
      
    $("#search-results").show()
    $.getJSON("/metadata/search?q=#{query}", (result) ->

      if result.length > 0
        for metadata in result
          id = "<td>#{metadata.record.id}</td>"
          name = "<td>#{metadata.record.name}</td>"
          if metadata[gon.metric]?
            score = "<td>#{metadata[gon.metric]}</td>"
          else
            score = ''
          row = "<tr>#{id}#{name}#{score}</tr>"
          $("#search-results>tbody").append(row)
      else
        $("#search-results").hide()
    )


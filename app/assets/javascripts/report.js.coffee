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
    $("#record-search").toggle()


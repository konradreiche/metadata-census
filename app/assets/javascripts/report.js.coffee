#=require d3
$ ->

  $(".report.repository-select").on 'change', (e) =>
    repository = $(".report.repository-select").val()
    window.location = "repository?show=#{repository}"

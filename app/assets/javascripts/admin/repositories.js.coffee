root = exports ? this

$ ->

  initImportLinks = () ->
    $("a.import-link").on "click", (event) ->
      file = $(this).data("file")
      $.post "/admin/repositories", { file: file }, (response) ->
        console.log response

  if root.isPath("/admin/repositories/new")
    initImportLinks()

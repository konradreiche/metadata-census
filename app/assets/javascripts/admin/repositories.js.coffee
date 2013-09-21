root = exports ? this

$ ->

  initLabels = () ->
    $(".label").hide()

  initImportLinks = () ->

    $("a.import-link").on "click", (event) ->
      anchor = $(this)
      anchor.hide()

      importingLabel = $(this).siblings(".label.label-info")
      doneLabel = $(this).siblings(".label.label-success")
      errorLabel = $(this).siblings(".label.label-danger")

      importingLabel.fadeIn()
      file = $(this).data("file")

      $.post("/admin/repositories", { file: file }, (response) =>
        importingLabel.fadeOut "fast", () =>
          doneLabel.fadeIn().fadeOut "fast", () =>
            anchor.show()

      ).error () =>
        importingLabel.fadeOut "fast", () =>
          errorLabel.fadeIn().fadeOut "fast", () =>
            anchor.show()

  initMetadataImportLinks = () ->

    $("a.metadata-import-link").on "click", (event) ->
      anchor = $(this)
      anchor.hide()

      importingLabel = $(this).siblings(".label.label-info")
      doneLabel = $(this).siblings(".label.label-success")
      errorLabel = $(this).siblings(".label.label-danger")

      importingLabel.fadeIn()
      file = $(this).data("file")
      repository = $(this).data("repository")

      data = { file: file }
      $.post("/admin/repositories/#{repository}/snapshots", data, (response) =>
        importingLabel.fadeOut "fast", () =>
          doneLabel.fadeIn().fadeOut "fast", () =>
            anchor.show()

      ).error () =>
        importingLabel.fadeOut "fast", () =>
          errorLabel.fadeIn().fadeOut "fast", () =>
            anchor.show()


  if root.isPath("/admin/repositories/new")
    initLabels()
    initImportLinks()
    initMetadataImportLinks()

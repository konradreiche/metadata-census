root = exports ? this

$ ->
  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metrics/accuracy")
    new Pagination("#mime-accuracy-pagination", ".mime-accuracy", 10)
    new Pagination("#size-accuracy-pagination", ".size-accuracy", 10)

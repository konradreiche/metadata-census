root = exports ? this

$ ->
  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metrics/accuracy")
    new Pagination("#mime-accuracy-pagination")

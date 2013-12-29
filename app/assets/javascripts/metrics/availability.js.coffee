root = exports ? this

$ ->
  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metrics/availability")
    new Pagination("#availability-pagination", ".responses", 10)

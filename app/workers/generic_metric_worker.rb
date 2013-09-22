class GenericMetricWorker < MetricWorker

  def perform(repository, metric, *args)
    @repository ||= Repository.find(repository)
    @metadata ||= @repository.snapshots.last.metadata_records
    @metric ||= Metrics.from_sym(metric).new
    super
  end

end

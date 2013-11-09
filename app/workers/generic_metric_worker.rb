class GenericMetricWorker < MetricWorker

  def perform(repository, snapshot, metric, *args)
    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(date: snapshot).first

    @metadata ||= MetadataRecord.where(snapshot: @snapshot)
    @metric ||= Metrics.from_sym(metric).new
    super
  end

end

class GenericMetricWorker < MetricWorker

  def perform(repository, metric, *args)
    @repository ||= Repository.find(repository)
    @metadata ||= @repository.metadata.to_a
    @metric ||= Metrics.from_sym(metric).new
    super
  end

end

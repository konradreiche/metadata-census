class GenericMetricWorker < MetricsWorker

  def perform(repository, metric, *args)
    @repository ||= Repository.find(repository)
    @metadata ||= @repository.metadata
    @metric ||= metric.to_s.camelcase.constantize.new
    super
  end

end

class RichnessOfInformationMetricWorker < MetricsWorker

  def perform(repository_name)
    repository = Repository.find repository_name
    metadata = repository.metadata
    metric = Metrics::RichnessOfInformation.new(metadata)
    compute(repository, metric)
  end

end

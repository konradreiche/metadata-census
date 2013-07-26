class RichnessOfInformationMetricWorker < MetricsWorker

  def perform(repository_name)
    store state: :loading
    logger.info 'Loading metadata'

    repository = Repository.find(repository_name)
    @metadata = repository.metadata

    store state: :analyzing
    logger.info 'Analyzing metadata'

    records = @metadata.map { |document| document[:record] }
    metric = Metrics::RichnessOfInformation.new(records, self)
    compute(repository, metric)
  end

end

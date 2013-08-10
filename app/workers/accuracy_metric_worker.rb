class AccuracyMetricWorker < MetricWorker

  def perform(repository_name)
    store state: :load
    logger.info('Loading metadata')

    repository = Repository.find(repository_name)
    @metadata = repository.metadata

    store state: :analyze
    logger.info 'Analyzing metadata'

    records = @metadata.map { |document| document[:record] }
    metric = Metrics::Accuracy.new(records, self)
    compute(repository, metric)
  end

end

class AccuracyMetricWorker < MetricsWorker

  def perform(repository_name)
    logger.info('Loading metadata')
    repository = Repository.find(repository_name)
    @metadata = repository.metadata
    logger.info 'Preprocessing metadata'
    records = @metadata.map { |document| document[:record] }
    metric = Metrics::Accuracy.new(records, self)
    compute(repository, metric)
  end

end

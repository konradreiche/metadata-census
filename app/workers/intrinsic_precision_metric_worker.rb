class IntrinsicPrecisionMetricWorker <  MetricWorker

  def perform(repository, metric)
    store stage: :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @metadata ||= @repository.snapshots.last.metadata_records

    store stage: :analyze
    logger.info('Analyzing metadata')

    language = @repository.language
    records = @metadata.map { |document| document.record }
    @metric = Metrics::IntrinsicPrecision.new(language)
    super
  end

end


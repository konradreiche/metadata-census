class IntrinsicPrecisionMetricWorker <  MetricWorker

  def perform(repository, snapshot, metric)
    store stage: :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(_id: snapshot).first
    @metadata ||= @snapshot.metadata_records

    store stage: :analyze
    logger.info('Analyzing metadata')

    @metric = Metrics::IntrinsicPrecision.new
    super
  end

end


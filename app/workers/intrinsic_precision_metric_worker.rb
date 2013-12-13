class IntrinsicPrecisionMetricWorker <  MetricWorker

  def perform(repository, snapshot, metric)
    store stage: :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(date: snapshot).first
    @metadata ||= MetadataRecord.where(snapshot: @snapshot)

    store stage: :analyze
    logger.info('Analyzing metadata')

    @metric = Metrics::IntrinsicPrecision.instance
    super
  end

end


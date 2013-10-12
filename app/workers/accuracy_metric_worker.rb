class AccuracyMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    store stage: :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(date: snapshot).first

    @metadata ||= @snapshot.metadata_records

    store stage: :analyze
    logger.info 'Analyzing metadata'

    records = @metadata.map { |document| document.record }
    @metric = Metrics::Accuracy.new(records, self)
    super
  end

end

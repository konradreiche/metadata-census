class AccuracyMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    store stage: :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(date: snapshot).first

    @metadata ||= MetadataRecord.where(snapshot: @snapshot)

    store stage: :analyze
    logger.info 'Analyzing metadata'

    records = @metadata.map { |document| document.record }
    @metric = Metrics::Accuracy.instance
    @metric.configure(records, self)

    store :stage => :compute
    @before = Time.new

    @metric.run()
    super
  end

end

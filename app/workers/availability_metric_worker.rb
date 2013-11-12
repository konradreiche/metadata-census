class AvailabilityMetricWorker <  MetricWorker

  def perform(repository, snapshot, metric)
    store :stage => :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(date: snapshot).first
    @metadata ||= MetadataRecord.where(snapshot: @snapshot)

    store :stage => :analyze
    logger.info('Analyzing metadata')

    @metadata = @metadata.only("record.id", "record.resources.url").to_a

    records = @metadata.map { |document| document.record }
    @metric = Metrics::Availability.new(records, self)
    
    store :stage => :compute
    @metric.run()
    super
  end

end


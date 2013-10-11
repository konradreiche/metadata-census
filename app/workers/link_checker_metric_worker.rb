class LinkCheckerMetricWorker <  MetricWorker

  def perform(repository, snapshot, metric)
    store :stage => :load
    logger.info('Loading metadata')

    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(_id: snapshot).first
    @metadata ||= @snapshot.metadata_records

    store :stage => :analyze
    logger.info('Analyzing metadata')

    @metadata = @metadata.only("record.id", "record.resources.url").to_a

    records = @metadata.map { |document| document.record }
    @metric = Metrics::LinkChecker.new(records, self)
    
    store :stage => :compute
    @metric.run()
    super
  end

end


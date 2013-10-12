class AccessibilityMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    @repository ||= Repository.find(repository)
    @snapshot ||= @repository.snapshots.where(date: snapshot).first

    @metadata ||= @snapshot.metadata_records
    @metadata = @metadata.only("record.notes", "record.resources.description")

    @metric = Metrics::Accessibility.new('en_us')
    super
  end

end

class AccessibilityMetricWorker < GenericMetricWorker

  def perform(repository, metric)
    @repository ||= Repository.find(repository)
    @metadata ||= @repository.snapshots.last.metadata_records
    @metadata = @metadata.only("record.notes", "record.resources.description")

    @metric = Metrics::Accessibility.new('en_us')
    super
  end

end

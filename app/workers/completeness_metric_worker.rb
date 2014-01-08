class CompletenessMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    @repository ||= Repository.find(repository)

    schema = JSON.parse(File.read('data/schema/ckan.json'))
    @metric = Metrics::Completeness.send(:new)
    @metric.configure(schema)

    super
  end

end

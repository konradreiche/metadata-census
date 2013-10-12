class CompletenessMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    @repository ||= Repository.find(repository)

    schema = JSON.parse(File.read('data/schema/ckan.json'))
    @metric = Metrics::Completeness.new(schema)
    super
  end

end

class CompletenessMetricWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(repository_name)
    repository = Repository.find repository_name
  end
end

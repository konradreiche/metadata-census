class Admin::MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  before_filter :init

  def schedule
    worker = MetricWorker.worker_class(@metric)
    job = Job.where(repository: @repository.id, metric: @metric)
    id = worker.send(:perform_async, @repository.id, @metric)

    if job.exists?
      job.first.update_attributes!(sidekiq_id: id)
    else
      Job.create!(sidekiq_id: id, repository: @repository.id, metric: @metric)
    end

    render nothing: true
  end

  private
  def init
    load_repositories(:repository_id)
    load_metrics(:metric_id)
  end


end

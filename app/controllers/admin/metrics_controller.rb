require 'sidekiq/testing/inline' if ENV['DEBUG']

class Admin::MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  before_filter :init

  def schedule
    worker = MetricWorker.worker_class(@metric)
    job = Job.find_by(repository: @repository.id, metric: @metric)
    id = worker.send(:perform_async, @repository.id, @metric)

    if not job.nil?
      job.update_attributes!(sidekiq_id: id)
    else
      Job.create!(sidekiq_id: id, repository: @repository.id, metric: @metric)
    end

    render nothing: true
  end

  def last_updated
    last_updated = DateTime.parse(@repository.send(@metric)[:last_updated])
    render json: { date: last_updated.strftime('%a %b %e %Y'),
                   time: last_updated.strftime('%T') }
  end

  private
  def init
    load_repositories(:repository_id)
    load_metrics(:metric_id)
  end


end

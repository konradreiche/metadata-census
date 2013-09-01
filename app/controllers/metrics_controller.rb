require 'sidekiq/testing/inline' if ENV['DEBUG']

class MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric 
  include Analysis::Metric

  helper_method :metric_score, :record, :select_partial

  @@jobs = Hash.new { |hash, key| hash[key] = Hash.new }
  
  def overview
    begin
      preprocess
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
  end

  def show
    load_repositories(:repository)
    load_metrics(:metric)
    load_records()

    analyze(@metric, @repository)
    gon.analysis = @analysis
    @score = @repository.send(@metric).maybe[:average]
    gon.score = @score
  end

  def status
    status = Hash.new { |hash, key| hash[key] = Hash.new }
    @@jobs.each do |repository, metrics|
      metrics.each  do |metric, id|
        status[repository][metric] = Sidekiq::Status::get_all(id)
        percent = Sidekiq::Status::pct_complete(id)
        status[repository][metric]['percent'] = percent.finite? ? percent : 0.0
      end
    end
    render :json => status
  end

  def compute
    load_repositories(:repository)
    load_metrics()
    @repositories.each do |repository|
      @metrics.each do |metric|
        worker = MetricWorker.worker_class(metric)
        id = worker.send(:perform_async, repository.name, metric)
        @@jobs[repository.name][metric] = id
      end
    end
    render :nothing => true
  end

  ##
  # Loads the metadata records in order to populate the metric view.
  #
  def load_records
    if params[:documents].nil?
      @documents = [@repository.best_record(@metric),
                    @repository.worst_record(@metric)]
    else
      @documents = params[:documents].map { |id| @repository.document(id) }
    end
  end

  def select_partial
    partials = "app/views/metrics/partials"
    metric_partial_path = "#{partials}/_#{@metric}.html.erb"
    metric_partial = "metrics/partials/#{@metric}"
    default_partial = "metrics/partials/default"
    File.exist?(metric_partial_path) ? metric_partial : default_partial
  end

end

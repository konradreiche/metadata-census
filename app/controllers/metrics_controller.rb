require 'sidekiq/testing/inline' if ENV['DEBUG']

class MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric 
  include Analysis

  helper_method :metric_score, :record, :select_partial

  @@jobs = Hash.new { |hash, key| hash[key] = Hash.new }
  
  def overview
  end

  def show
    load_repositories(:repository)
    load_metrics(:metric)
    load_records()

    analyze()
    gon.analysis = @analysis

    score = @repository.snapshots.last.send(@metric)
    @score = Metrics::normalize(@metric, score[:average])
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
    load_metrics(:metric)

    worker = MetricWorker.worker_class(@metric)
    id = worker.send(:perform_async, @repository.name, @metric)
    @@jobs[@repository.name][@metric] = id

    render :nothing => true
  end

  ##
  # Loads the metadata records in order to populate the metric view.
  #
  def load_records
    if params[:documents].nil?
      snapshot = @repository.latest_snapshot
      @documents = [snapshot.best_record(@metric),
                    snapshot.worst_record(@metric)]
    else
      @documents = params[:documents].map { |id| MetadataRecord.find(id) }
    end
    gon.documents = @documents
  end

  ##
  # Selects the partial for displaying the metric report.
  #
  # The selection is done based on the current metric. Either there is a
  # specific partial or a generic partial is returned as fallback.
  #
  def select_partial
    partials = "app/views/metrics/partials"
    metric_partial_path = "#{partials}/_#{@metric}.html.erb"
    metric_partial = "metrics/partials/#{@metric}"
    generic_partial = "metrics/partials/generic"
    File.exist?(metric_partial_path) ? metric_partial : generic_partial
  end

end

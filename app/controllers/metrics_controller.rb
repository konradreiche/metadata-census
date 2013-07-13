class MetricsController < ApplicationController

  @@jobs = Hash.new

  def overview
    begin
      preprocess
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
  end

  def status
    status = {}
    @@jobs.each do |metric, id|
      status[metric] = Sidekiq::Status::get_all(id)
      percent = Sidekiq::Status::pct_complete(id)
      status[metric]['percent'] = percent.finite? ? percent : 0.0
    end
    render :json => status
  end

  def preprocess
    @repositories = Repository.all
    if params[:repository].nil?
      @selected = @repositories.first if @selected.nil?
    else
      @selected = Repository.find params[:repository]
    end
    gon.repository = @selected.to_hash
  end

  def accuracy_stats
    preprocess
    stats = Hash.new 0

    repository = params[:repository]
    if repository.nil?
      repository = @selected
    else
      repository = Repository.find repository
    end

    size = 0.0
    metadata = all_metadata(repository)
    metadata.each do |document|
      document[:resources].each do |resource|
        format = resource[:format]
        format = resource[:mimetype] unless resource[:mimetype].nil?
        next if format.nil?
        size += 1
        stats[format.downcase] += 1
      end
    end
    stats = stats.inject([]) do |result, item|
      result << { "format" => item[0],
                  "frequency" => item[1] / size }
    end
    gon.data = stats
  end

  def compute
    repository_name = params[:repository]
    metric = params[:metric]

    repository = Repository.find(repository_name)

    case metric
    when 'completeness'
      id = CompletenessMetricWorker.perform_async(repository_name)
    when 'weighted-completeness'
      id = WeightedCompletenessMetricWorker.perform_async(repository_name)
    when 'richness-of-information'
      id = RichnessOfInformationMetricWorker.perform_async(repository_name)
    when 'accuracy'
      id = AccuracyMetricWorker.perform_async(repository_name)
    when 'accessibility'
      id = AccessibilityMetricWorker.perform_async(repository_name)
    end
    @@jobs[metric] = id
    render :text => '0.0'
  end


end

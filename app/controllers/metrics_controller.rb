class MetricsController < ApplicationController

  def overview
    preprocess
  end

  def apply_metric(repository, metric, name, *args)

    scores = []
    Rails.logger.info "Apply metric %s" % name
    metadata = repository.metadata
    metadata.each_with_index do |document, i|

      input = document.to_hash
      input = symbolize_keys(input)
      metric.compute(input, *args)

      scores << metric.score if metric.score.finite?
      input[name.to_sym] = metric.score
      Tire.index 'metadata' do
        update('ckan', document.id,
          :doc => input)
        refresh
      end

      Rails.logger.info "#{i + 1} / #{metadata.size}"
    end
    process_scores(scores, repository, name)
  end

  def process_scores(scores, repository, metric)
    scores.sort!
    minimum = scores.first
    maximum = scores.last
    average = scores.inject(:+) / scores.length
    median = scores[scores.length / 2]
    
    result = Score.new(minimum, maximum, average, median)
    repository.send "#{metric}=", result
    repository.update_index
        
    median
  end

  def completeness(repository)
    schema = JSON.parse File.read 'public/ckan-schema.json'
    schema = symbolize_keys(schema)
    metric = Metrics::Completeness.new
    apply_metric(repository, metric, 'completeness', schema)
  end

  def weighted_completeness(repository)
    schema = JSON.parse File.read 'public/ckan-schema.json'
    schema = symbolize_keys(schema)
    metric = Metrics::WeightedCompleteness.new 'public/ckan-weight.yml'
    apply_metric(repository, metric, 'weighted_completeness', schema)
  end

  def richness_of_information(repository)
    metadata = all_metadata(repository).map { |i| symbolize_keys(i.to_hash) }
    metric = Metrics::RichnessOfInformation.new metadata
    apply_metric(repository, metric, 'richness_of_information')
  end

  def accuracy(repository)
    metric = Metrics::Accuracy.new
    apply_metric(repository, metric, 'accuracy')
  end
  
  def accessibility(repository)
    metric = Metrics::Accessibility.new 'en_us'
    apply_metric(repository, metric, __method__)
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

    repository = Repository.find repository_name

    case metric
    when 'completeness'
      CompletenessMetricWorker.perform_async(repository_name)
    when 'weighted-completeness'
      result = weighted_completeness(repository)
    when 'richness-of-information'
      result = richness_of_information(repository)
    when 'accuracy'
      result = accuracy(repository)
    when 'accessibility'
      result = accessibility(repository)
    end

    render :text => result
  end

end

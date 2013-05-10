class MetricsController < ApplicationController

  def overview
    preprocess
  end

  def apply_metric(repository, metric, name, *args)

    scores = []
    Rails.logger.info "Apply metric %s" % name
    metadata = all_metadata(repository)
    metadata.each_with_index do |document, i|

      input = document.to_hash
      input = symbolize_keys(input)
      metric.compute(input, *args)

      scores << metric.score
      document.send "#{name}=", metric.score
      document.update_index
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

  def symbolize_keys arg
    case arg
    when Array
      arg.map { |elem| symbolize_keys elem }
    when Hash
      Hash[arg.map do |key, value|
        k = key.is_a?(String) ? key.to_sym : key
        v = symbolize_keys value
        [k,v]
      end]
    else
      arg
    end
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

  def preprocess
    @repositories = Repository.all
    @selected = @repositories.first if @selected.nil?
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
    stats = stats.inject([]) { |result, item| result << { "format" => item[0],
                                                          "frequency" => item[1] / size } }
    gon.data = stats
  end

  def compute
    repository = params[:repository]
    metric = params[:metric]

    repository = Repository.find repository

    case metric
    when 'completeness'
      result = completeness(repository)
    when 'weighted-completeness'
      result = weighted_completeness(repository)
    when 'richness-of-information'
      result = richness_of_information(repository)
    when 'accuracy'
      result = accuracy(repository)
    end

    render :text => result
  end

  def all_metadata(repository)
    Rails.logger.info "Load all metadata"
    CkanMetadatum.all.select { |i| i.repository == repository.name }
  end

end

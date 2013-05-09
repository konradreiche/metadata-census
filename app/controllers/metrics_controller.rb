class MetricsController < ApplicationController

  def overview
    preprocess
  end

  def apply_metric(repository, metric, name, *args)

    scores = []
    Rails.logger.info "Apply metric %s" % name
    metadata = all_metadata(repository)
    metadata.each_with_index do |document, i|
      metric.compute(document.to_hash, *args)
      scores << metric.score
      require 'pry'; binding.pry
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

  def recursive_symbolize_keys! hash
    hash.symbolize_keys!
    hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
  end

  def completeness(repository)
    schema = JSON.parse File.read 'public/ckan-schema.json'
    recursive_symbolize_keys!(schema)
    metric = Metrics::Completeness.new
    apply_metric(repository, metric, 'completeness', schema)
  end

  def weighted_completeness(repository)
    schema = JSON.parse File.read 'public/ckan-schema.json'
    recursive_symbolize_keys!(schema)
    metric = Metrics::WeightedCompleteness.new 'public/ckan-weight.yml'
    apply_metric(repository, metric, 'weighted_completeness', schema)
  end

  def richness_of_information(repository)
    metric = Metrics::RichnessOfInformation.new all_metadata(repository)
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

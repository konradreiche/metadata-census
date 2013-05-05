class MetricsController < ApplicationController

  def overview
    @repositories = Repository.all
    @selected = @repositories.first if @selected.nil?
  end

  def apply_metric(repository, metric, name, *args)

    scores = []
    for document in all_metadata(repository)
      metric.compute(document, *args)
      scores << metric.score
      break
    end
    
    scores.sort!
    minimum = scores.first
    maximum = scores.last
    average = scores.inject(:+) / scores.length
    median = scores[scores.length / 2]
    
    result = Score.new(minimum, maximum, average, median)
    repository.send "#{name}=", result
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
    metric = Metrics::RichnessOfInformation.new documents
    apply_metric(repository, metric, 'richness_of_information')
  end

  def accuracy(repository)
    metric = Metrics::Accuracy.new
    apply_metric(repository, metric, 'accuracy')
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
    p "sp"
    Tire.search 'metadata' do
      query { string 'repository:' + repository.name }
      size 10000
    end.results.to_a.map { |document| document.to_hash }
    p "done"
  end

end

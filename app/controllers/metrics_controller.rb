class MetricsController < ApplicationController

  def overview
    @repositories = Repository.all
    @selected = @repositories.first if @selected.nil?
  end

  def apply_metric(repository, metric, name, *args)
    scores = []

    documents = Tire.search 'metadata' do
      query { string 'repository:' + repository.name }
    end.results

    for entry in documents
      document = JSON.parse entry.to_json
      metric.compute document, *args
      scores << metric.score
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

  def completeness(repository)
    schema = JSON.parse File.read 'public/ckan-schema.json'
    metric = Metrics::Completeness.new
    apply_metric(repository, metric, 'completeness', schema)
  end

  def weighted_completeness(repository)
    schema = JSON.parse File.read 'public/ckan-schema.json'
    metric = Metrics::WeightedCompleteness.new 'public/ckan-weight.yml'
    apply_metric(repository, metric, 'weighted_completeness', schema)
  end

  def richness_of_information(repository)
    documents = Tire.search 'metadata' do
      query { string 'repository:' + repository.name }
    end.results

    metric = Metrics::RichnessOfInformation.new documents
    apply_metric(repository, metric, 'richness_of_information')
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
    end

    render :text => result
  end

end

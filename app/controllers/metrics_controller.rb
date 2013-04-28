class MetricsController < ApplicationController

  def overview
    @repositories = Repository.all
    @selected = @repositories.first if @selected.nil?
  end

  def completeness(repository)

    schema = JSON.parse File.read 'public/ckan-schema.json'
    scores = []

    documents = Tire.search 'metadata' do
      query { string 'repository:' + repository.name }
    end.results


    for entry in documents
      metric = Metrics::Completeness.new
      document = JSON.parse entry.to_json
      metric.compute document, schema
      scores << metric.score
    end

    scores.sort!
    minimum = scores.first
    maximum = scores.last
    average = scores.inject(:+) / scores.length
    median = scores[scores.length / 2]
    
    repository.completeness = Score.new(minimum, maximum, average, median)
    repository.update_index
        
    median
  end

  def weighted_completeness(repository)
    documents = Tire.search 'metadata' do
      query { string 'repository:' + repository }
    end.results

    schema = JSON.parse File.read 'public/ckan-schema.json'
    scores = []

    for entry in documents
      metric = Metrics::WeightedCompleteness.new 'public/ckan-weight.yml'
      document = JSON.parse entry.to_json
      metric.compute document, schema
      scores << metric.score
    end
    scores.inject(:+) / scores.length
  end

  def richness_of_information(repository)
    documents = Tire.search 'metadata' do
      query { string 'repository:' + repository }
    end.results.map { |doc| JSON.parse doc.to_json }

    scores = []
    metric = Metrics::RichnessOfInformation.new documents
    for document in documents
      metric.compute document
      scores << metric. score
    end
    scores.inject(:+) / scores.length
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

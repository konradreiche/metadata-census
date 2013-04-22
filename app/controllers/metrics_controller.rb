class MetricsController < ApplicationController
  def overview
  end

  def completeness
    documents = Tire.search 'ckan' do
      query { all }
    end.results

    schema = JSON.parse File.read 'public/ckan-schema.json'
    scores = []

    for entry in documents
      metric = Metrics::Completeness.new
      document = JSON.parse entry.to_json
      metric.compute document, schema
      scores << metric.score
    end

    redirect_to :action => 'overview', :score => scores.inject(:+) / scores.length
  end

  def weighted_completeness
    documents = Tire.search 'ckan' do
      query { all }
    end.results

    schema = JSON.parse File.read 'public/ckan-schema.json'
    scores = []

    for entry in documents
      metric = Metrics::WeightedCompleteness.new 'public/ckan-weight.yml'
      document = JSON.parse entry.to_json
      metric.compute document, schema
      scores << metric.score
    end

    redirect_to :action => 'overview', :score => scores.inject(:+) / scores.length
  end

  def richness_of_information
    documents = Tire.search 'ckan' do
      query { all }
    end.results.map { |doc| JSON.parse doc.to_json }

    scores = []
    metric = Metrics::RichnessOfInformation.new documents
    for document in documents
      metric.compute document
      scores << metric. score
    end

    redirect_to :action => 'overview', :score => scores.inject(:+) / scores.length
  end
end

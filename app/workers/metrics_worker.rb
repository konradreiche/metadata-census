class MetricsWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def compute(repository, metric, *args)
    scores = []
    metadata = repository.metadata

    require 'pry'; binding.pry
    metadata.each_with_index do |record, i|
        document = self.class.symbolize_keys(record.to_hash)
      metric.compute(document, *args)
      scores << metric.score
      update_document(document, metric)
    end

    update_repository(repository, scores)
    refresh
  end

  def update_document(document, metric)
    document[metric.name] = metric.score
    Tire.index 'metadata' do
      update('ckan', document.id, :doc => input)
    end
  end

  def update_repository(repository, metric, scores)
    scores.sort!
    minimum = scores.first
    maximum = scores.last
    average = scores.inject(:+) / scores.length
    median = scores[scores.length / 2]

    score = Scores.new(minimum, maximum, average, median)
    repository.update_score(metric, score)
    repository.update_index
  end

  def refresh
    Tire.index('metadata') { refresh }
  end

  def self.symbolize_keys arg
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

end
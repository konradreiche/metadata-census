class MetricsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def compute(repository, metric, *args)

    scores = []
    if @metadata.nil?
      store state: :load
      logger.info 'Loading metadata'
      @metadata = repository.metadata
    end

    store state: :compute
    logger.info 'Compute metadata scores'

    total = @metadata.length
    @metadata.each_with_index do |document, i|
      record = self.class.symbolize_keys(document.to_hash)[:record]
      metric.compute(record, *args)
      scores << metric.score
      update_document(document, metric)
      at(i + 1, total)
    end

    update_repository(repository, metric, scores)
    refresh
  end

  def update_document(document, metric)
    metric_name = metric.name.to_sym
    document[metric_name] = { score: metric.score }

    if metric.respond_to?(:report)
      document[metric_name][:report] = metric.report
    end

    Tire.index 'metadata' do
      update('ckan', document[:id], :doc => document)
    end
  end

  def update_repository(repository, metric, scores)
    scores.sort!
    minimum = scores.first
    maximum = scores.last
    average = scores.inject(:+) / scores.length
    median = scores[scores.length / 2]

    score = Score.new(minimum, maximum, average, median)
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

##
# Base metric worker which all metric worker have to subclass.
#
class MetricWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(repository, metric, *args)
    scores = []
    store :state => :compute
    logger.info('Compute metadata scores')

    @metadata.each_with_index do |document, i|
      record = document.record.with_indifferent_access
      score, analysis = @metric.compute(record, *args)

      document[metric] = { score: score }
      document[metric][:analysis] = analysis
      document.save!

      scores << score
      at(i + 1, @metadata.length)
    end

    update_repository(metric, scores)
  end

  def update_repository(metric, scores)
    scores.sort!
    min = scores.first
    max = scores.last
    avg = scores.inject(:+) / scores.length
    med = scores[scores.length / 2]

    score = { minimum: min, maximum: max, average: avg, median: med }
    @repository[metric] = score
    @repository.save!
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

  ## Derive the metric worker class
  #
  # Uses +metric+ to dynamically retrieve the corresponding metric worker class
  # which is used to instantiate a new computation job. If there is no metric
  # worker matching the metric the default generic worker is returned.
  #
  def self.worker_class(metric)
    begin
      (metric.to_s.camelcase + "MetricWorker").constantize
    rescue NameError
      GenericMetricWorker
    end
  end

end

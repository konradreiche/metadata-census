require 'time'

##
# Base metric worker which all metric worker have to subclass.
#
class MetricWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(repository, metric, *args)
    scores = []
    store :stage => :compute
    logger.info('Compute metadata scores')

    @metadata.each_with_index do |document, i|
      document[metric] = Hash.new if document[metric].nil?

      record = document.record
      score, analysis = @metric.compute(record, *args)

      document.send(metric)['score'] = score
      document.send(metric)['analysis'] = analysis
      document.save!

      scores << score
      at(i + 1, @metadata.length)
    end

    update_snapshot(metric, scores)
  end

  def update_snapshot(metric, scores)
    snapshot = @repository.snapshots.last
    score = Hash.new

    scores = scores.reject(&:nan?)
    scores.sort!

    score['minimum'] = scores.first
    score['maximum'] = scores.last
    score['average'] = scores.inject(:+) / scores.length
    score['median'] = scores[scores.length / 2]

    snapshot[metric] = score
    snapshot[metric]['last_updated'] = DateTime.now.to_s
    snapshot.save!
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
      (metric.to_s.underscore.camelcase + "MetricWorker").constantize
    rescue NameError
      GenericMetricWorker
    end
  end

end

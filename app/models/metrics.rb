module Metrics

  def self.list
    initialize if Rails.env.development?
    cls = Metrics::Metric
    cls.metrics
  end

  ## Eager load all metric classes
  # 
  # In development environment the metric classes are wiped per request. This
  # method helps to manually load them.
  #
  def self.initialize
    directory = self.to_s.downcase
    path = Rails.root.join("app/models/#{directory}/*.rb")
    Dir[path].each { |metric_file| load metric_file }
  end

  def self.normalize(metric, values)
    return values unless Metrics.from_sym(metric).normalize?
    scores = values
    repositories = Repository.all
    repositories.each do |repository|
      score = repository.send(metric)
      unless score.nil?
        scores << score[:minimum]
        scores << score[:maximum]
      end
    end
    min = scores.min
    max = scores.max
    range = max - min
    values.map { |value| (value - min) / range }
  end

  def self.from_sym(symbol)
    "#{self.name}::#{symbol.to_s.camelcase}".constantize
  end

  def self.url(metric)
    metric.to_s.gsub('_', '-')
  end

  def self.internal(metric)
    metric.to_s.gsub('-', '_')
  end

end

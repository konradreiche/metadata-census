module Metrics

  IDENTIFIERS = [:completeness,
                 :weighted_completeness,
                 :richness_of_information,
                 :accuracy,
                 :accessibility,
                 :link_checker]

  ABBREVIATIONS = [:C, :WC, :RoI, :ACCU, :ACCE, :LC]

  NORMALIZE = [:richness_of_information,
               :accessibility]

  def self.metrics
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

    unless NORMALIZE.include?(metric)
      return values
    end

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

  def self.get_url_representation(metric)
    metric.to_s.gsub('_', '-')
  end

  def self.get_internal_representation(metric)
    metric.to_s.gsub('-', '_')
  end

end

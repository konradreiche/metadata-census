module Metrics

  IDENTIFIERS = [:completeness,
                 :weighted_completeness,
                 :richness_of_information,
                 :accuracy,
                 :accessibility,
                 :link_checker]

  NORMALIZE = [:richness_of_information,
               :accessibility]

  def self.normalize(metric, values)

    unless NORMALIZE.include?(metric)
      return values
    end

    scores = []
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
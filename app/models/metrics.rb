module Metrics

  IDENTIFIER = [:completeness,
                :weighted_completeness,
                :richness_of_information,
                :accuracy,
                :accessibility,
                :link_checker]

  NORMALIZE = [:richness_of_information,
               :accessibility]

  def self.normalize(metric, values)
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
    values.map { |value| 100 * (value - min) / range }
  end

end

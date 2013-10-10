module Analyzer

  class QualityDistribution

    def analyze(snapshot)
      metadata = snapshot.metadata_records.without(:record)
      scores = metadata.map(&:score).map { |score| score * 100 }
      grouped = scores.group_by { |score| (score / 10).to_i }

      grouped.each_with_object({}) do |(group, values), distribution|
        distribution[group * 10] = values.length
      end
    end

  end

end

module Analyzer

  class QualityDistribution

    def analyze(snapshot)
      metadata = snapshot.metadata_records.without(:record)
      metadata.map(&:score).map { |score| score * 100 }
    end

  end

end

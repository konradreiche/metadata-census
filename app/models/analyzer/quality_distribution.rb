module Analyzer

  class QualityDistribution

    def analyze(snapshot)
      metadata = snapshot.metadata_records.without(:record)
      metadata.map(&:score).map { |score| score * 100 }
    end

    def distribution(snapshot, metric)
      metadata = snapshot.metadata_records.without(:record)
      metadata.map { |document| document[metric]['score'] * 100 }
    end

    def records(snapshot, distribution)
      metadata = snapshot.metadata_records.without(:record)
      metadata.map do |document| 
        { id: document.id, score: document.score * 100 }
      end.group_by { |document| document[:score].to_i / 10 * 10 }[distribution]
    end

  end

end

module Analyzer

  class QualityDistribution

    def analyze(snapshot)
      metadata = MetadataRecord.where(snapshot: snapshot).without(:record)
      metadata.map(&:score).compact.map { |score| score * 100 }
    end

    def distribution(snapshot, metric)
      metadata = MetadataRecord.where(snapshot: snapshot).without(:record)
      metadata.map { |document| document[metric].maybe['score'].to_f * 100 }
    end

    def records(snapshot, distribution)
      metadata = MetadataRecord.where(snapshot: snapshot)
      metadata = metadata.only('score', 'record.id', 'record.name')
      metadata.map do |document| 
        url = "#{snapshot.repository.url}/rest/dataset/#{document.record['name']}"
        { id: document.record['id'], score: document.score * 100, name: document.record['name'], url: url }
      end.group_by { |document| document[:score].to_i / 10 * 10 }[distribution]
    end

  end

end

module Analyzer

  class QualityDistribution

    def analyze(snapshot)
      metadata = MetadataRecord.where(snapshot: snapshot).only(:score)
      metadata.options[:fields]['_id'] = 0
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

    def self.records_by_score(snapshot, metric, range)
      metadata = MetadataRecord.where(snapshot: snapshot)
      score_field = "#{metric.id}.score"

      metadata = metadata.between(score_field => range)
      metadata = metadata.only('id', 'record.id', 'record.name', score_field)
      metadata.limit(10).map do |document|
        { 'id'     => document.id,
          'score'  => document[score_field],
          'record' => { 'id'   => document.record['id'],
                        'name' => document.record['name'] }
        }
      end
    end

  end

end

module Analyzer

  class IntrinsicPrecision < Generic

    class << self
      alias_method :__analyze__, :analyze
    end
    
    def self.analyze(snapshot, metric)
      analyses = __analyze__(snapshot, metric)
      analyses['misspellings'] = misspellings(snapshot, metric)
      analyses
    end

    def self.misspellings(snapshot, metric)
      metadata = snapshot.metadata_records.only(metric.id)
      metadata.to_a.inject(Hash.new(0)) do |statistic, document|

        document.send(metric.id)['analysis'].each do |analysis|
          analysis['misspelled'].each { |word| statistic[word] += 1 }
        end
        statistic

      end
    end

  end

end

module Analyzer

  class IntrinsicPrecision < Generic

    class << self
      alias_method :__analyze__, :analyze
    end
    
    def self.analyze(repository, metric)
      analyses = __analyze__(repository, metric)
      analyses[:misspellings] = misspellings(repository, metric)
      analyses
    end

    def self.misspellings(repository, metric)
      metadata = repository.snapshots.last.metadata_records.only(metric)
      metadata.to_a.inject(Hash.new(0)) do |statistic, document|

        document.send(metric)[:analysis].each do |analysis|
          analysis[:misspelled].each { |word| statistic[word] += 1 }
        end
        statistic

      end
    end

  end

end

module Analyzer

  class IntrinsicPrecision < Generic

    class << self
      alias_method :__analyze__, :analyze
    end
    
    def self.analyze(repository, metric)
      analyses = __analyze__(repository, metric)
      analyses[:misspellings] = misspellings(repository, metric)
    end

    def self.misspellings(repository, metric)
      metadata = repository.snapshots.last.metadata_records.only(metric)
      metadata.inject(Hash.new(0)) do |statistic, document|
        document.intrinsic_precision[:misspelled].each do |misspelling|
          statistic[misspelling] += 1
        end
      end
    end

  end

end

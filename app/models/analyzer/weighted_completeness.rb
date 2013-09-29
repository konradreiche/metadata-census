module Analyzer
  class WeightedCompleteness < Completeness

    def self.analyze(repository, metric)
      self.superclass.method(__method__).call(repository, metric)
    end

  end
  
end

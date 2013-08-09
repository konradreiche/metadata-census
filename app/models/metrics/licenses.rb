module Metrics

  class Licenses < Metric

    attr_reader :score

    def initialize
      @score = 0.0
    end

    def compute(record)
    end

  end

end

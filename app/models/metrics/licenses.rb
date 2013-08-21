module Metrics

  class Licenses < Metric

    attr_reader :score

    def license_valid?(id)
      licenses = { "dl-de-by-1.0" => true }
      licenses[id]
    end

    def initialize
      @score = 0.0
    end

    def compute(record)
      license = record[:license_id]
      @score = 1.0 if license_valid?(license)
    end

  end

end

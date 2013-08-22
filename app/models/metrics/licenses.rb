module Metrics

  class Licenses < Metric

    attr_reader :score, :report

    def initialize(path=nil)
      path = 'app/assets/resources/licenses.json' if path.nil?
      @score = 0.0
      @licenses = JSON.parse(File.read(path)).with_indifferent_access
    end

    def license_open?(id)
      return false if @licenses[id].nil?
      @licenses[id][:is_okd_compliant] || @licenses[id][:is_osi_compliant]
    end

    def compute(record)
      @score = 0.0
      license = record[:license_id]
      @score = 1.0 if license_open?(license)
      @report = license
    end

  end

end

module Metrics

  class Licenses < Metric

    attr_reader :report

    def initialize(path=nil)
      path = 'app/assets/resources/licenses.json' if path.nil?
      @licenses = JSON.parse(File.read(path)).with_indifferent_access
    end

    def license_open?(id)
      return false if @licenses[id].nil?
      @licenses[id][:is_okd_compliant] || @licenses[id][:is_osi_compliant]
    end

    def compute(record)
      license = record[:license_id]
      @report = license
      return 1.0 if license_open?(license)
      0.0
    end

  end

end

module Metrics

  class Openness < Metric

    attr_reader :analysis

    def initialize(path=nil)
      path = 'data/licenses.json' if path.nil?
      @licenses = JSON.parse(File.read(path))
      @analysis = Hash.new(0)
    end

    def license_open?(id)
      return false if @licenses[id].nil?
      @licenses[id]['is_okd_compliant'] || @licenses[id]['is_osi_compliant']
    end

    def compute(record)
      license = record['license_id'].maybe.gsub('.', "\uff0e")
      @analysis[license] += 1

      return 1.0, license if license_open?(license)
      return 0.0, license
    end

  end

end

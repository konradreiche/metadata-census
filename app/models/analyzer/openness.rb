module Analyzer
  class Openness

    def self.analyze(snapshot, metric)
      licenses = JSON.parse(File.read('data/licenses.json'))
      open = []
      licenses.each do |id, properties|
        if properties['is_okd_compliant'] or properties['is_osi_compliant']
          open << id
        end
      end
      open
    end

  end
end

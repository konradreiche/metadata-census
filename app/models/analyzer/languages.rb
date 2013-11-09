module Analyzer

  class Languages

    UT = 'TG_UNKNOWN_LANGUAGE'

    def initialize
      @fields = YAML.load(File.read('data/schema/fields.yml'))
    end

    def analyze(snapshot)
      documents = MetadataRecord.where(snapshot: snapshot)
      documents.each_with_object(Hash.new(0)) do |document, languages|
        detection = detect(document, :CKAN)

        if detection[:reliable]
          detection[:name] = 'Unknown' if detection[:name] == UT
          languages[detection[:name].titlecase] += 1
        else
          languages['Unreliable'] += 1 if not detection[:reliable]
        end
      end
    end

    def detect(document, type)
      corpus = @fields[type][:text].inject([]) do |corpus, accessor|
        corpus << Metrics::Metric.value(document.record, accessor)
      end.join(' ')

      return CLD.detect_language(corpus)
    end

  end

end

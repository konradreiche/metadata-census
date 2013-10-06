module Analyzer

  class Languages

    def initialize
      @fields = YAML.load(File.read('data/schema/fields.yml'))
    end

    def analyze(snapshot)
      documents = snapshot.metadata_records
      documents.each_with_object(Hash.new(0)) do |document, languages|
        detection = detect(document, :CKAN)
        languages[detection[:name].titlecase] += 1 if detection[:reliable]
        languages[detection['Unreliable']] += 1 if not detection[:reliable]
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

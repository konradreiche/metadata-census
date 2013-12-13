module Metrics
  class IntrinsicPrecision < Metric

    def initialize
      @fields = { :text => [['notes'], ['resources', 'description']] }
      @directory = Dir['data/misspelling/*']
      @misspelling = Hash.new
      super()
    end

    def self.description
      <<-TEXT.strip_heredoc
      The intrinsic precision measures measures common spelling mistakes. Only
      fields containing continious text, like notes or resource description are
      tested for the spelling mistakes.
      TEXT
    end

    def compute(record)

      language = language(record)
      load_misspelling(language) if @misspelling[language].nil?
      analysis = []

      @fields[:text].each do |accessor|
        value = self.class.value(record, accessor)

        Array(value).each_with_index do |text, i|
          score = 1.0

          misspelled = Metric.words(text.to_s).inject([]) do |misspellings, word|
            misspellings << word if @misspelling[language].to_h.key?(word)
            misspellings
          end.uniq

          path = value.is_a?(Array) ? accessor + [i + 1] : accessor
          score = 0.0 unless misspelled.empty?

          analysis << { field: path, score: score, language: language,
                        misspelled: misspelled }
        end
      end

      if analysis.any? { |a| a[:score] == 0.0 }
        return 0.0, analysis
      else
        return 1.0, analysis
      end

    end

    def language(record)
      detection = CLD.detect_language(corpus(record))
      return detection if detection.nil?

      detection[:name].to_s.downcase.to_sym
    end

    def corpus(record)
      @fields[:text].inject(Array.new) do |values, accessor|
        values << self.class.value(record, accessor)
      end.join(' ')
    end

    private
    def load_misspelling(language)
      path = "data/misspelling/#{language}.yml"
      return if language.nil? or not File.exists?(path)

      yaml = File.read(path)
      @misspelling[language] = YAML.load(yaml)
    end

  end
end

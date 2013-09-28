module Metrics

  class IntrinsicPrecision < Metric

    def initialize(language)
      @language = language.to_s.downcase.to_sym

      @babel = WhatLanguage.new(:german, :english)
      @fields = { :text => [[:notes], [:resources, :description]] }

      @directory = Dir['data/spelling/*']
      @misspelling = Hash.new
    end

    def self.description
      description = <<-TEXT.strip_heredoc
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

          misspelled = @misspelling[language].keys.select do |misspelling|
            text.include?(misspelling)
          end.uniq

          path = value.is_a?(Array) ? accessor + [i + 1] : accessor
          score = 0.0 unless misspelled.empty?
          analysis << { field: path, score: score, misspelled: misspelled }
        end
      end

      if analysis.any? { |a| a[:score] == 0.0 }
        return 0.0, analysis
      else
        return 1.0, analysis
      end

    end

    def language(record)
      detection = @babel.language(corpus(record))
      detection ||= @language
    end

    def corpus(record)
      @fields[:text].inject(Array.new) do |values, accessor|
        values << self.class.value(record, accessor)
      end.join(' ')
    end

    private
    def load_misspelling(language)
      yaml = File.read("data/spelling/#{language}.yml")
      @misspelling[language] = YAML.load(yaml)
    end

  end
end

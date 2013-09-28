module Metrics

  class IntrinsicPrecision < Metric

    def initialize
      @babel = WhatLanguage.new(:all)
      @fields = { :text => [[:notes], [:resources, :description]] }
    end

    def self.description
      description = <<-TEXT.strip_heredoc
      TEXT
    end

    def compute(record)
      analysis = []
      all_words = all_mistakes = 0
      language = language(record)

      @fields[:text].each do |accessor|
        value = self.class.value(record, accessor)

        Array(value).each_with_index do |text, i|
          next if skip?(text)

          misspelled = []
          words = mistakes = 0

          self.class.words(text.to_s).each do |word|
            words += 1
            all_words += 1
            next if /\d/.match(word)

            if not speller.correct?(word)
              mistakes += 1
              all_mistakes += 1
              misspelled << word
            end
          end

          path  = value.is_a?(Array) ? accessor + [i + 1] : accessor
          score = 1.0 - mistakes.fdiv(words)

          analysis << { field: path, score: score,
                        misspelled: misspelled.uniq }
        end
      end

      score = 1.0 - all_mistakes.fdiv(all_words)
      
      return score, analysis
    end

    def language(record)
      @babel.language(corpus(record))
    end

    def corpus(record)
      @fields[:text].inject(Array.new) do |values, accessor|
        values << self.class.value(record, accessor)
      end.join(' ')
    end

  end
end

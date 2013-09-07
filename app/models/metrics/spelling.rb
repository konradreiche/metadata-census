module Metrics

  class Spelling < Metric

    def initialize
      @wl = WhatLanguage.new(:all)
      @fields = { :text => [[:notes], [:resources, :description]] }
    end

    def self.description
      description = <<-TEXT
      The spelling metric measures the number of spelling mistakes on metadata
      record fields that are used for descriptive fields. While the number of
      spelling mistakes is an arguable quality factor it should be clear that
      misspelled terms make it for some metadata records less likely to be
      found.
      TEXT
      description.lstrip.rstrip
    end

    def compute(record)
      analysis = Hash.new
      all_words = all_mistakes = 0
      speller = aspell(detect_language(record))

      @fields[:text].each do |accessor|
        value = self.class.value(record, accessor)
        Array(value).each_with_index do |text, i|
          misspelled = []
          words = mistakes = 0
          words(text.to_s).each do |word|
            all_words = words += 1
            next if word.length < 7

            unless speller.correct?(word)
              all_mistakes = mistakes += 1
              misspelled << word
            end
          end
          path  = value.is_a?(Array) ? accessor + [i + 1] : accessor
          score = 1.0 - mistakes.fdiv(words)
          analysis[path] = { score: score, misspelled: misspelled.uniq }
        end
      end

      score = 1.0 - all_mistakes.fdiv(all_words)
      return score, analysis
    end

    def detect_language(record)
      detection_text = @fields[:text].reduce('') do |text, accessor|
        text + Array(self.class.value(record, accessor)).join(' ')
      end
      @wl.language(detection_text)
    end

    def aspell(language)
      codes = { english: 'en', german: 'de', spanish: 'es' }
      aspell = FFI::Aspell::Speller.new(codes[language])
      aspell
    end

    def words(text)
      text.split /\W+/
    end

  end
end

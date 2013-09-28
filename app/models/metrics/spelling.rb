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
      analysis = []
      all_words = all_mistakes = 0
      speller = aspell(detect_language(record))

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

    def detect_language(record)
      detection_text = @fields[:text].reduce('') do |text, accessor|
        text + Array(self.class.value(record, accessor)).join(' ')
      end
      @wl.language(detection_text)
    end

    def aspell(language)
      codes = { english: 'en', german: 'de', spanish: 'es' }
      FFI::Aspell::Speller.new(codes[language])
    end

  end
end

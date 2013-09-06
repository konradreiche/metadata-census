module Metrics

  class Spelling < Metric

    def initialize
      @wl = WhatLanguage.new(:all)
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
      detection_text = record[:notes].to_s
      record[:resources].to_a.each do |resource|
        detection_text += resource[:description].to_s
      end

      language = @wl.language(detection_text)
      speller = aspell(language)

      words = 0
      mistakes = 0
      words(record[:notes].to_s).each do |word|
        words += 1
        next if word.length < 7
        correct = speller.correct?(word)
        mistakes += 1 unless correct
        Sidekiq.logger.warn word unless correct
      end
      record[:resources].to_a.each do |resource|
        words(resource[:description].to_s).each do |word|
          words += 1
          next if word.length < 7
          correct = speller.correct?(word)
          mistakes += 1 unless correct
          Sidekiq.logger.warn word unless correct
        end
      end

      score = 1.0 - mistakes.to_f / words.to_f
      return score
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

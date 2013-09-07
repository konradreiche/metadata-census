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
      words = 0
      mistakes = 0
      analysis = Hash.new
      speller = aspell(detect_language(record))

      @fields[:text].each do |accessor|
        value = value(record, accessor)
        index = value.is_a?(Array)
        Array(value).each_with_index do |text, i|
          w = 0
          m = 0
          words(text.to_s).each do |word|
            w += 1
            words += 1
            next if word.length < 7
            correct = speller.correct?(word)
            m += 1 unless correct
            mistakes += 1 unless correct
            if index
              analysis[accessor + [i]] = [m, w]
            else
              analysis[accessor] = [m, w]
            end
            Sidekiq.logger.warn(word) unless correct
          end
        end
      end

      score = 1.0 - mistakes.to_f / words.to_f
      return score, analysis
    end

    def detect_language(record)
      detection_text = @fields[:text].reduce('') do |text, accessor|
        text + Array(value(record, accessor)).join(' ')
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

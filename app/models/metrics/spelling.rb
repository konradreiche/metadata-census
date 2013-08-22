module Metrics
  class Spelling < Metric

    def initialize
      @wl = WhatLanguage.new(:all)
    end

    def compute(record)

      detection_text = record[:notes].to_s
      record[:resources].each do |resource|
        detection_text += resource[:description].to_s
      end

      language = @wl.language(detection_text)
      speller = aspell(language)

      words = 0
      mistakes = 0
      words(record[:notes].to_s).each do |word|
        words += 1
        mistakes += 1 unless speller.correct?(word)
      end
      record[:resoures].each do |resource|
        words(resource[:description].to_s).each do |word|
          words += 1
          mistakes += 1 unless speller.correct?(word)
        end
      end

      mistakes.to_f / words.to_f
    end

    def aspell(language)
      codes = { english: 'en', german: 'de', spanish: 'es' }
      Aspell.new(codes[language])
    end

    def words(text)
      text.split /\W+/
    end

  end
end

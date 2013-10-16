require 'text/hyphen'
require 'tactful_tokenizer'

module Metrics

  class Accessibility < Metric

    def initialize(language)
      @fields = { text: [['notes'], ['resources', 'description']] }
      @sentence_tokenizer = TactfulTokenizer::Model.new

      options = { language: language, left: 0, right: 0 }
      @word_hyphenizer = Text::Hyphen.new(options)
    end

    def compute(record)
      scores, analysis = [], []

      @fields[:text].each do |accessor|
        text = self.class.value(record, accessor)

        if text.is_a?(Array)
          text.each_with_index do |text, i|
            next if skip?(text)
            score = flesch_reading_ease(text)

            analysis << { field: accessor + [i], score: score }
            scores << score
          end
        else
          next if skip?(text)
          score = flesch_reading_ease(text)

          analysis << { field: accessor, score: score }
          scores << score
        end
      end

      return 0.0, analysis if scores.empty?
      return scores.reduce(:+).fdiv(scores.length), analysis
    end

    def split_sentences(text)
      @sentence_tokenizer.tokenize_text(text)
    end

    def sentences(text)
      split_sentences(text).length
    end

    def hyphenate(word)
      if word.empty?
        nil
      else
        word.length == 1 ? [] : @word_hyphenizer.hyphenate(word)
      end
    end

    def syllables(word)
      hyphens = hyphenate(word)
      (hyphens.nil?) ? 0 : hyphens.length + 1
    end

    def flesch_reading_ease(text)
      sentences = sentences(text)
      words = words(text)
      syllables = words.map { |word| syllables(word) }.reduce(:+)

      # average sentence length
      asl = words.length / sentences
      # average number of syllables per word
      asw = syllables / words.length

      flesch = 206.835 - (1.015 * asl) - (84.6 * asw)
      flesch = [0, flesch].max
      flesch = [100, flesch].min
      
      return flesch / 100.0
    end

    def self.description
      <<-TEXT.strip_heredoc
      The accessibility metric measures the metadata records in mean of
      cognitive accessibility. In order to measure the accessibility different
      reading indices are used.
      TEXT
    end

  end
end

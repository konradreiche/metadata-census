require 'text/hyphen'
require 'tactful_tokenizer'

module Metrics

  class Accessibility < Metric

    attr_reader :score

    def initialize(language)
      @sentence_tokenizer = TactfulTokenizer::Model.new
      @word_hyphenizer = Text::Hyphen.new(:language => language, :left => 0,
                                          :right => 0)
    end

    def compute(data)
      scores = []
      if not data[:notes].nil? and not skip?(data[:notes])
        scores << flesch_reading_ease(data[:notes])
      end

      unless data[:resources].nil?
        data[:resources].each do |resource|
          if not resource[:description].nil? and not skip?(resource[:description])
            scores << flesch_reading_ease(resource[:description])
          end
        end
      end

      unless scores.empty?
        @score = scores.reduce(:+) / scores.size
        require 'pry'; binding.pry unless @score.finite?
      else
        @score = 0.0
      end
    end

    def self.split_to_words(text)
      text.split /\W+/
    end

    def self.words(text)
      split_to_words(text).length
    end

    def split_into_sentences(text)
      @sentence_tokenizer.tokenize_text(text)
    end

    def sentences(text)
      split_into_sentences(text).length
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
      sentences = sentences(text).to_f
      words = Accessibility.words(text).to_f
      syllables = Accessibility.split_to_words(text).map do |word|
        syllables(word)
      end.sum.to_f

      # average sentence length
      asl = words / sentences
      # average number of syllables per word
      asw = syllables / words
      206.835 - (1.015 * asl) - (84.6 * asw)
    end

  end
end

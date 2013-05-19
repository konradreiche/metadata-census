require 'text/hyphen'
require 'tactful_tokenizer'

module Metrics

  class Accessibility

    def initialize(language)
      @sentence_tokenizer = TactfulTokenizer::Model.new
      @word_hyphenizer = Text::Hyphen.new(:language => language, :left => 0,
                                          :right => 0)
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
    end

  end
end

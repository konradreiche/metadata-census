require 'text/hyphen'
require 'tactful_tokenizer'

module Metrics

  class Accessibility

    def initialize(language)
      @sentence_tokenizer = TactfulTokenizer::Model.new
    end

    def self.split_to_words(text)
      text.split /\W+/
    end

    def split_into_sentences(text)
      @sentence_tokenizer.tokenize_text(text)
    end

  end
end

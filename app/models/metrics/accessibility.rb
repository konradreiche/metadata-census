require 'text/hyphen'
require 'tactful_tokenizer'

module Metrics

  class Accessibility

    def initialize(language)
    end

    def self.split_to_words(text)
      text.split /\W+/
    end

    def self.split_into_sentences(text)
      []
    end

  end
end

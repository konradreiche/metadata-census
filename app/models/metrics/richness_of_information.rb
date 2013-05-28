module Metrics

  class RichnessOfInformation < Metric

    attr_reader :score, :document_numbers, :document_frequency

    def initialize(datasets)
      @document_frequency = Hash.new(0)
      @document_numbers = 0.0
      for entry in datasets
        index_field(entry, :notes, entry[:id])
        for resource in entry[:resources]
          index_field(resource, :description, entry[:id])
        end
      end
    end

    def index_field(entity, field, id)
      if entity.has_key?(field) and not entity[field].nil?
        @document_numbers += 1
        entity[field].downcase.split(/\W+/).each do |word|
          unless @document_frequency[word].include?(id)
            @document_frequency[word] = @document_frequency[word] << id
          end
        end
      end
    end

    def self.term_frequency(data)
      term_frequency = Hash.new(0)
      doc_length = 0

      term_frequency, doc_length = count_words(data, :notes, term_frequency, doc_length)
      for resource in data[:resources]
        result = count_words(resource, :description, term_frequency, doc_length)
        term_frequency, doc_length = result
      end
      [term_frequency, doc_length.to_f]
    end

    def self.count_words(entity, field, term_frequency, doc_length)
      unless entity[field].nil?
        entity[field].downcase.split(/\W+/).each do |word|
          term_frequency[word] += 1
        end
        doc_length += 1
      end
      [term_frequency, doc_length]
    end

    def compute(data)
      term_frequency, doc_length = self.class.term_frequency(data[:resources])
      factors = []
      term_frequency.each do |word, count| 
        factors << count / doc_length.to_f * Math.log(@document_numbers / @document_frequency[word].length)
      end
      @score = factors.inject(:+) / term_frequency.length.to_f unless term_frequency.length == 0
    end
  end

end

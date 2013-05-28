module Metrics

  class RichnessOfInformation < Metric

    attr_reader :score, :document_numbers, :document_frequency

    def initialize(metadata)
      @document_frequency = Hash.new { |h,k| h[k] = [] }
      @document_numbers = 0.0
      for record in metadata
        index_field(record, :notes, record[:id])
        for resource in record[:resources]
          index_field(resource, :description, record[:id])
        end
      end
    end

    def index_field(record, field, id)
      unless record[field].nil?
        @document_numbers += 1
        record[field].downcase.split(/\W+/).each do |word|
          unless @document_frequency[word].include?(id)
            @document_frequency[word] << id
          end
        end
      end
    end

    def self.term_frequency(data)
      term_frequency = count_words(data, :notes, Hash.new(0))
      for resource in data[:resources]
        term_frequency = count_words(resource, :description, term_frequency)
      end
      term_frequency
    end

    def self.count_words(entity, field, term_frequency)
      unless entity[field].nil?
        words = entity[field].downcase.split(/\W+/)
        words.each do |word|
          term_frequency[word] += 1
        end
      end
      term_frequency
    end

    def compute(data)
      term_frequency, doc_length = self.class.term_frequency(data)
      tf_idfs = []
      term_frequency.each do |word, tf| 
        idf = Math.log(@document_numbers / @document_frequency[word].length)
        tf_idfs << tf * idf
      end
      @score = tf_idfs.inject(:+) / term_frequency.length
    end
  end

end

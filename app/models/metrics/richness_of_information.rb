module Metrics

  class RichnessOfInformation < Metric

    attr_reader :score

    def initialize(datasets)
      @document_frequency = Hash.new []
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

    def compute(data)
      term_frequency = Hash.new 0
      doc_length = 0
      for resource in data[:resources]
        if resource.has_key?(:description) and not resource[:description].nil?
          resource[:description].downcase.split(/\W+/).each do |w|
            term_frequency[w] += 1
            doc_length += 1
          end
        end
      end

      factors = []
      term_frequency.each do |word, count| 
        factors << count / doc_length.to_f * Math.log(@document_numbers / @document_frequency[word].length)
      end
      @score = factors.inject(:+) / term_frequency.length.to_f unless term_frequency.length == 0
    end
  end

end

module Metrics

  class RichnessOfInformation

    attr_reader :score

    def initialize(datasets)
      @document_frequency = Hash.new []
      @document_numbers = 0.0
      require 'pry'; binding.pry
      for entry in datasets
        for resource in entry['resources']
          if resource.has_key?('description') and not resource['description'].nil?
            @document_numbers += 1
            resource['description'].downcase.split(/\W+/).each do |word|
              unless @document_frequency[word].include?(entry['id'])
                @document_frequency[word] = @document_frequency[word] << entry['id']
              end
            end
          end
        end
      end
    end

    def compute(data)
      term_frequency = Hash.new 0
      doc_length = 0
      for resource in data['resources']
        if resource.has_key?('description') and not resource['description'].nil?
          resource['description'].downcase.split(/\W+/).each do |w|
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

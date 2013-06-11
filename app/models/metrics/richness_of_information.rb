module Metrics

  class RichnessOfInformation < Metric

    attr_reader :score, :document_numbers, :document_frequency

    def initialize(metadata)
      @text_fields = ["notes", "resources.description"]
      @document_frequency = Hash.new { |h,k| h[k] = [] }
      @document_numbers = 0.0
      for record in metadata
        index_field(record, :notes, record[:id])
        for resource in record[:resources]
          index_field(resource, :description, record[:id])
        end
      end
    end

    def compute(data)
      scores = []
      @text_fields.each do |field|
        value = self.class.value(data, field)
        if value.is_a?(Array)
          value.each { |item| scores << tf_idf(item) }
        else
          scores << tf_idf(value)
        end
      end
      @score = scores.inject(:+) / scores.length
    end

    def tf_idf(text)
      tf_idfs = []
      term_frequency = self.class.term_frequency(text)
      term_frequency.each do |word, tf| 
        idf = Math.log(@document_numbers / @document_frequency[word].length)
        tf_idfs << tf * idf
      end
      tf_idfs.inject(:+) / term_frequency.length
    end

    def self.value(data, field)
      accessors = field.split(/\./).map { |a| a.to_sym }
      accessors.inject(data) do |value, accessor|
        if value.is_a?(Array)
          value.map { |item| item[accessor] }
        else
          value[accessor]
        end
      end
    end

    def self.term_frequency(text)
      term_frequency = Hash.new(0)
        words = text.downcase.split(/\W+/)
        words.each do |word|
          term_frequency[word] += 1
        end
      term_frequency
    end

    private
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

  end
end

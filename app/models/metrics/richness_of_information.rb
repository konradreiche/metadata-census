module Metrics

  class RichnessOfInformation < Metric

    attr_reader :score, :document_numbers, :document_frequency

    def initialize(metadata)
      @text_fields = [[:notes], [:resources, :description]]
      @document_frequency = Hash.new { |h,k| h[k] = [] }
      @document_numbers = 0.0
      metadata.each do |record|
        @text_fields.each do |accessors|
          index_fields(record, accessors.dup, [record[:id]])
        end
      end
    end

    def compute(data)
      scores = []
      @text_fields.each do |accessors|
        value = self.class.value(data, accessors)
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

    def self.value(data, accessors)
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
    def index_text(text, id)
      unless text.nil?
        @document_numbers += 1
        text.downcase.split(/\W+/).each do |word|
          unless @document_frequency[word].include?(id)
            @document_frequency[word] << id
          end
        end
      end
    end

    def index_fields(record, accessors, id)
      while not accessors.empty?
        accessor = accessors.shift
        id << accessor
        if record[accessor].is_a?(Array)
          record[accessor].each_with_index do |item, i|
            index_fields(item, accessors.dup, id + [i])
          end
        else
          record = record[accessor]
        end
      end
      index_text(record, id)
    end
  end
end

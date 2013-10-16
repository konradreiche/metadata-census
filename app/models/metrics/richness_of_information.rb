module Metrics

  class RichnessOfInformation < Metric

    attr_reader :document_numbers, :document_frequency,
      :categorical_frequency, :analysis

    def initialize(metadata, worker=nil)
      @fields = {:category => [['tags']],
                 :text => [['notes'], ['resources', 'description']]}

      @document_frequency = Hash.new { |h,k| h[k] = [] }
      @categorical_frequency = Hash.new { |h,k| h[k] = Hash.new(0) }
      @document_numbers = 0.0

      metadata.each_with_index do |record, i|
        @fields.each do |type, fields|
          fields.each do |accessors|
            index_fields(record, accessors.dup, [record['id']], type)
          end
        end
        worker.at(i + 1, metadata.length) unless worker.nil?
      end

      df = @document_frequency.each_with_object({}) do |(k,v),h|
        h[k] = v.length
      end

      @analysis = { document_frequency: df,
                    categorical_frequency: @categorical_frequency,
                    document_numbers: @document_numbers }
    end

    def self.description
      "The Richness of Information metric measures the uniqueness of a metadata
      record. The more unique its content is the higher the probability that it
      contains meaningful and not redundant content."
    end

    def compute(data)
      scores = []
      analysis = []

      @fields.each do |type, fields|
        fields.each do  |accessors|
          value = self.class.value(data, accessors)
          if value.is_a?(Array)
            value.each_with_index do |item, i|
              next if skip?(item)
              score = richness_of_information(item, type, accessors)
              analysis << { field: accessors + [i], score: score }
              scores << score
            end
          else
            next if skip?(value)
            score = richness_of_information(value, type, accessors)
            analysis << { field: accessors, score: score }
            scores << score
          end
        end
      end

      return score(scores), analysis
    end

    def score(scores)
      unless scores.empty?
        scores.inject(:+) / scores.length
      else
        0.0
      end
    end

    def richness_of_information(value, type, category=nil)
      case type
      when :category
        count = @categorical_frequency[category][value]
        total = categorical_frequency[category].values.reduce(:+).to_f
        1.0 - Math.log(count) / Math.log(total)
      when :text
        tf_idf(value)
      end
    end

    def tf_idf(text)
      tf_idfs = []
      term_frequency = self.class.term_frequency(text)
      euclidean_length = Math.sqrt term_frequency.values.map { |tf| tf * tf }.sum

      term_frequency.each do |word, tf| 
        idf = Math.log(@document_numbers / @document_frequency[word].length)
        tf_idfs << tf.fdiv(euclidean_length) * idf
      end
      tf_idfs.inject(:+) / term_frequency.length
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

    def index_category(category, value)
      unless value.nil?
        @categorical_frequency[category][value] += 1
      end
    end

    def index_fields(record, accessors, id, type)
      if type == :category
        value = self.class.value(record, accessors)
        if value.is_a?(Array)
          value.each { |item| index_category(accessors, item)  }
        else
          index_category(accessors, value)
        end
      else
        while not record.nil? and not accessors.empty?
          accessor = accessors.shift
          id << accessor
          if record[accessor].is_a?(Array)
            record[accessor].each_with_index do |item, i|
              index_fields(item, accessors.dup, id + [i], type)
            end
          else
            record = record[accessor]
          end
        end
        index_text(record, id)
      end
    end

    def self.normalize?
      true
    end

  end

end

module Metrics
  class Metric

    def name
      self.class.to_sym
    end
    
    def self.to_sym
      self.name.demodulize.underscore.dasherize.to_sym
    end

    def self.description
      ""
    end

    def self.words(text)
      text.scan(/\S+/).map do |word|
        word.split(/(\p{Letter}.*\p{Letter})/)[1]
      end
    end

    ## Skip null fields and fields with whitespace strings
    #
    # Checks +value+ whether it is a null-valued field. A string is also null
    # if it contains only whitespace.
    # 
    def skip?(value)
      value.nil? or (value.is_a?(String) and value !~ /[^[:space:]]/)
    end

    def self.normalize?
      false
    end

    ## List the metrics for dynamically generating the view
    # 
    def self.metrics
      @@metrics
    end

    ## Keeps track of metric subclasses
    #
    # This method is called everytime a subclass of +Metrics::Metric+ is
    # created and adds the subclass to the list of metrics.
    #
    def self.inherited(subclass)
      @@metrics ||= []
      @@metrics << subclass.to_sym
    end

    ##
    # Retrieves a value fromm the record based on the provided accessor path.
    #
    # Used by metrics that need to retrieve values from a specified set of
    # fields. For instance the Spelling and Richness of Information metric.
    #
    def self.value(record, accessors)
      accessors.inject(record) do |value, accessor|
        if value.is_a?(Array)
          if accessor.is_a?(Fixnum)
            value[accessor]
          else
            value.map { |item| item[accessor] unless item.nil? }
          end
        else
          value[accessor] unless value.nil?
        end
      end
    end

  end

end

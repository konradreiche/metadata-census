module Metrics
  class Metric

    def name
      self.class.to_sym
    end
    
    def self.to_sym
      self.name.demodulize.underscore.to_sym
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

  end

end

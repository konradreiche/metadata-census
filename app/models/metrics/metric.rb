module Metrics
  class Metric

    def name
      self.class.name.underscore.split('/').last
    end

    ## Skip null fields and fields with whitespace strings
    #
    # Checks +value+ whether it is a null-valued field. A string is also null
    # if it contains only whitespace.
    # 
    def skip?(value)
      value.nil? or (value.is_a?(String) and value !~ /[^[:space:]]/)
    end

    ## List the metrics for dynamically generating the view
    # 
    def self.metrics
      @@metrics
    end

    def self.inherited(subclass)
      @@metrics ||= []
      metric = subclass.to_s.split('::').last.underscore.to_sym
      @@metrics << metric
    end

  end
end

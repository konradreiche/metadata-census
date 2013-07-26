module Metrics
  class Metric

    def name
      self.class.name.underscore.split('/').last
    end

     def skip?(value)
       value.nil? or (value.is_a?(String) and value !~ /[^[:space:]]/)
     end

  end
end

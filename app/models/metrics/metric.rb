module Metrics
  class Metric

    def name
      self.class.name.underscore.split('/').last
    end

  end
end

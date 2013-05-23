module Metrics
  class Metric

    def name
      self.name.undersore.gsub('_', '-')
    end

  end
end

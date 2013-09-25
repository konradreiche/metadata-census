module Analysis

  ##
  # Selects an analyzer based on the metric.
  #
  def analyze
    module_name = self.method(__method__).owner
    metric_class = @metric.to_s.underscore.camelcase

    analyzer = "#{module_name}::#{metric_class}".constantize
    @analysis = analyzer.analyze(@repository, @metric)
  rescue NameError
    metric_class = :Generic
    analyzer = "#{module_name}::#{metric_class}".constantize
    @analysis = analyzer.analyze(@repository, @metric)
  end

end

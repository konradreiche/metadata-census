module Analysis::Metric

  def analyze(metric, repository)
    cls = "#{self.method(__method__).owner}::#{metric.to_s.camelcase}"
    @analysis = cls.constantize.analyze(repository)
  rescue
    # swallow
  end
  
end

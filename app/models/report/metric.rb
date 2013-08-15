module Report::Metric

  def report(metric, repository)
    cls = "Report::Metric::#{metric.to_s.camelcase}"
    @report = cls.constantize.report(repository)
  rescue
    # swallow
  end
  
end

module Analysis::Metric

  def analyze(metric, repository)
    cls = "#{self.method(__method__).owner}::#{metric.to_s.camelcase}"
    @analysis = cls.constantize.analyze(repository)
  rescue Exception => e
    logger.error(e)
  end

  ##
  # Generates statistics based on a metric and a group
  #
  # The group is determined through an accessor path.
  #
  def group_scores_by(metric, repository, group)
  end
  
end

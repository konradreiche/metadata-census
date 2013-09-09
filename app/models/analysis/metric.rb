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
  def self.group_scores_by(repository, metric, group)
    metadata = repository.query(metric, group)
    groups = Hash.new { |hash, key| hash[key] = [] }

    metadata.each do |document|
      document[group].each do |group|
        groups[group] << document
      end
    end

    groups.each do |group, documents|
      groups[group] = documents.inject(0.0) do |score, document|
        score + document[metric][:score]
      end / documents.length
    end
    groups
  end
  
end

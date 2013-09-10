module Analysis::Metric

  def analyze(metric, repository)
    cls = "#{self.method(__method__).owner}::#{metric.to_s.camelcase}"
    @analysis = cls.constantize.analyze(repository)
  rescue Exception => e
    logger.error(e)
  end

  ##
  # Generates statistics based on all the sub-scores.
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

  ##
  # Generates statistics based on the details of metric results.
  #
  # Counts the occurences of detail values.
  #
  def self.group_details_by(repository, metric)
    metadata = repository.query(metric)
    details = Hash.new(0)

    metadata.each do |document|
      # iterate the detail values of the metric analysis data
      document[metric][:analysis].to_h.each do |field, analysis|
        analysis.except(:score).values.first.each do |detail|
          details[detail] += 1
        end
      end
    end
    details
  end
  
end

module Analysis

  class Default

    def self.analyze(repository, metric)
      scores = group_scores_by(repository, metric, :"record.groups")
      details = group_details(repository, metric)
      return { scores: scores, details: details }
    end

    ##
    # Generates statistics based on all the sub-scores.
    #
    # The group is determined through an accessor path.
    #
    def self.group_scores_by(repository, metric, group)
      metadata = repository.latest_snapshot.query(metric, group)
      groups = Hash.new { |hash, key| hash[key] = [] }

      metadata.each do |document|
        document[group].each do |group|
          groups[group] << document
        end
      end

      groups.each do |group, documents|
        groups[group] = documents.inject(0.0) do |score, document|
          score + document[metric]["score"]
        end / documents.length
      end
      groups
    end

    ##
    # Generates statistics based on the details of metric results.
    #
    # Counts the occurences of detail values. The default case would assume that
    # there are two keys in the metric analysis. The first is the sub-score. The
    # other value would contain somewhat counting information. If there are more
    # than two additional keys, the first one is chosen.
    #
    def self.group_details(repository, metric)
      metadata = repository.latest_snapshot.query(metric)
      details = Hash.new(0)

      metadata.each do |document|
        # iterate the detail values of the metric analysis data
        document[metric][:analysis].to_h.each do |field, analysis|
          analysis.except(:score).values.first.each do |detail|
            details[detail] += 1
          end
        end
      end
      thin_out(details)
    end

    private
    ## 
    # Thins out the values by replacing values that go below a certain
    # threshold into its own key.
    #
    def self.thin_out(details, threshold=15)
      others = 0
      details.each do |key, value|
        if value < threshold
          others += value
          details.delete(key)
        end
      end
      details["Others"] = others
      details
    end

  end
  
end

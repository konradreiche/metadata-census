module Analysis

  class Generic

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
      snapshot = repository.snapshots.last
      metadata = snapshot.metadata_records.only(metric, group)
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
      snapshot = repository.snapshots.last
      metadata = snapshot.metadata_records.only(metric)
      details = Hash.new(0)

      metadata.each do |document|
        # iterate the detail values of the metric analysis data
        document.send(metric)[:analysis].to_a.each do |analysis|
          score = analysis[:score].round
          details[score] += 1
        end
      end
      thin_out(details)
    end

    private
    ## 
    # Thins out the values by replacing values that go below a certain
    # threshold into its own key.
    #
    def self.thin_out(details, threshold=0)
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

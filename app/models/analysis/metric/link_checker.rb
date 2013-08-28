module Analysis::Metric

  class LinkChecker

    def self.analyze(repository)
      analysis = OpenStruct.new
      responses = Hash.new { |hash, key| hash[key] = Hash.new }
      distribution = Hash.new(0)
      repository.metadata.each do |document|
        unless document[:link_checker].maybe[:analysis].nil?
          document_analysis = document[:link_checker][:analysis]
          responses[document[:record][:id]] = document_analysis
          document_analysis.each { |url, response| distribution[response] += 1 }
        end
      end
      analysis.responses = responses
      analysis.distribution = distribution
      analysis.gon = distribution
      analysis
    end

  end

end

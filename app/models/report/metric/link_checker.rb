module Report::Metric

  class LinkChecker

    def self.report(repository)
      report = OpenStruct.new
      responses = Hash.new
      distribution = Hash.new(0)
      repository.metadata.each do |document|
        unless document[:link_checker].maybe[:report].nil?
          document_report = document[:link_checker][:report]
          responses.merge!(document_report)
          document_report.each { |url, response| distribution[response] += 1 }
        end
      end
      report.responses = responses
      report.distribution = distribution
      report
    end

  end

end

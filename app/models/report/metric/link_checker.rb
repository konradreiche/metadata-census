module Report::Metric

  class LinkChecker

    def self.report(repository)
      responses = Hash.new
      repository.metadata.each do |document|
        unless document[:link_checker].maybe[:report].nil?
          responses.merge!(document[:link_checker][:report])
        end
      end
      responses
    end

  end

end

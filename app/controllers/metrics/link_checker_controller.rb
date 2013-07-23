class Metrics::LinkCheckerController < MetricsReportController

  helper_method :success?

  def report
    super
    @url_request_responses = Hash.new
    metadata = @repository.fetch_metadata
    metadata.each do |document|
      @url_request_responses.merge! document[:link_checker_details]
    end
  end

  def success?(code)
    if code.is_a?(Fixnum) and code >= 200 and code < 300
      'successful'      
    else
      'unsuccessful'
    end
  end

end

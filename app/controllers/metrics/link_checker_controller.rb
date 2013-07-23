class Metrics::LinkCheckerController < MetricsReportController

  def report
    super
    @url_request_responses = Hash.new
    metadata = @repository.fetch_metadata
    metadata.each do |document|
      @url_request_responses.merge! document[:link_checker_details]
    end
    logger.info @url_request_responses.first
  end

end

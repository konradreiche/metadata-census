require 'typhoeus'

module Metrics

  class LinkChecker < Metric
    attr_reader :score

    def initialize(metadata, worker=nil)
      @worker = worker
      @total = metadata.length
      @resource_availability = Hash.new
      metadata.each_with_index do |dataset, i|
        dataset[:resources].each do |resource|
          @resources += 1
          url = resource[:url]
          enqueue_request(url)
        end
        @worker.at(i + i, @total)
      end
    end

  end

end

require 'typhoeus'

module Metrics

  class LinkChecker < Metric
    attr_reader :score

    def initialize(metadata, worker=nil)
      @worker = worker
      @processed = 0
      @requests = 0
      @total = metadata.length
      @dispatcher = Typhoeus::Hydra.hydra

      @resource_availability = Hash.new { |h, k| h[k] = Hash.new }
      metadata.each_with_index do |dataset, i|
        dataset[:resources].each do |resource|
          @total += 1
          url = resource[:url]
          id = dataset[:id]
          enqueue_request(id, url)
        end
        @worker.at(i + i, @total)
      end
    end

    def compute(record)
      @score = 0.0

      # blocking call
      @dispatcher.run
      id = record[:id]
      responses = @resource_availability[id].values
      @score = responses.select { |r| success?(r) }.size / responses.size.to_f
      @score = 0.0 unless @score.finite?
    end

    def success?(response_code)
      if response_code.is_a?(Fixnum)
        response_code >= 200 and response_code < 300
      else
        false
      end
    end

    def enqueue_request(id, url)

      config = {:method => :head,
                :timeout => 20,
                :connecttimeout => 10,
                :nosignal => true}

      request = Typhoeus::Request.new(url, config)
      request.on_complete do |response|
        @resource_availability[id][url] = response_value(response)
        @worker.at(@processed + 1, @requests)
        @processed += 1
      end
      @dispatcher.queue(request)
      @requests += 1
    end

    def response_value(response)
      if response.success?
        response.code
      elsif response.timed_out?
        'Timed out'
      elsif response.code == 0
        'Error: ' + response.return_message
      else
        response.code
      end
    end

  end

end

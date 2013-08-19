require 'typhoeus'
require 'uri'

module Metrics

  class LinkChecker < Metric
    attr_reader :score, :report

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
        @worker.at(i + i, @total) unless @worker.nil?
      end
    end

    def compute(record)
      @worker.at(@processed, @requests) unless @worker.nil?
      @score = 0.0

      # blocking call
      @dispatcher.run
      id = record[:id]
      responses = @resource_availability[id].values
      @score = responses.select { |r| success?(r) }.size / responses.size.to_f
      @report = @resource_availability[id]
      @score = 0.0 unless @score.finite?
    end

    def success?(response_code)
      if response_code.is_a?(Fixnum)
        response_code >= 200 and response_code < 300
      else
        false
      end
    end

    def enqueue_request(id, url, method=:head)

      config = { headers: { 'User-Agent' => 'curl/7.29.0' },
                 ssl_verifypeer: false,
                 ssl_verifyhost: 2,  # disable host verification
                 followlocation: true,
                 connecttimeout: 120,
                 method: method,
                 nosignal: true,
                 timeout: 180 }

      escaped = URI.escape(url, "[]")
      request = Typhoeus::Request.new(escaped, config)
      request.on_complete do |response|
        response_value = response_value(response)
        if client_error?(response_value, method)
          @requests -= 1
          enqueue_request(id, url, :get)
        else
          @resource_availability[id][url] = response_value
          @worker.at(@processed + 1, @requests) unless @worker.nil?
          @processed += 1
        end
      end
      @dispatcher.queue(request)
      @requests += 1
    end

    ##
    # Checks whether the response is a HTTP 4xx client error
    # 
    # If there is a client error the probability is high that the link check
    # cannot be reduced to a HTTP header request. In this case a full GET
    # request is issued afterwards.
    #
    def client_error?(response, method)
      method == :head && response.is_a?(Fixnum) &&
        response >= 400 && response < 500 
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

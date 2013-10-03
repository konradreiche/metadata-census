require 'typhoeus'
require 'uri'

module Metrics

  class LinkChecker < Metric

    def initialize(metadata, worker=nil)
      @worker = worker
      @processed = 0
      @requests = 0
      @total = metadata.length

      @dispatcher = Typhoeus::Hydra.hydra
      @resource_availability = Hash.new { |h, k| h[k] = Hash.new }

      metadata.each_with_index do |dataset, i|
        dataset[:resources].to_a.each do |resource|
          url = URI.unescape(resource[:url])
          id = dataset[:id]

          raise KeyError, 'Record ID must not be null' if id.nil?
          enqueue_request(id, url)
        end
        @worker.at(i, metadata.length) unless @worker.nil?
      end
    end

    def run
      @dispatcher.run
    end

    def compute(record)
      # blocking call
      @dispatcher.run

      id = record[:id]
      responses = @resource_availability[id].values

      @report = @resource_availability[id]
      score = responses.select { |r| success?(r) }.size / responses.size.to_f

      return 0.0, @report unless score.finite?
      return score, @report
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
                 connecttimeout: 60,
                 method: method,
                 nosignal: true,
                 timeout: 240,
                 verbose: true }

      request = Typhoeus::Request.new(url, config)
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

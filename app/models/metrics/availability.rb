require 'typhoeus'
require 'uri'

module Metrics

  class Availability < Metric

    attr_reader :analysis

    def initialize(metadata, worker=nil)
      @worker = worker
      @processed = 0

      @requests = 0
      @total = metadata.length
      @analysis = Hash.new(0)

      @dispatcher = Typhoeus::Hydra.hydra
      @resource_availability = Hash.new { |h, k| h[k] = Hash.new }

      metadata.each_with_index do |dataset, i|
        dataset['resources'].to_a.each do |resource|
          url = URI.unescape(resource['url'])
          id = dataset['id']

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

      id = record['id']
      responses = @resource_availability[id].values

      analysis = @resource_availability[id].to_a
      score = responses.select { |r| success?(r) }.size.fdiv(responses.size)

      return 0.0, analysis unless score.finite?
      return score, analysis
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
                 connecttimeout: 60,
                 maxredirs: 50,
                 followlocation: true,
                 method: method,
                 nosignal: true,
                 timeout: 240 }

      request = Typhoeus::Request.new(url, config)
      request.on_complete do |response|
        response_message = response_message(response)

        if client_error?(response_message, method)
          @requests -= 1
          enqueue_request(id, url, :get)
        else
          @resource_availability[id][url] = response_message
          @analysis[response_message] += 1

          @worker.at(@processed + 1, @requests) unless @worker.nil?
          @worker.eta(@processed + 1, @requests) unless @worker.nil?

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

    def response_message(response)
      if response.return_code == :too_many_redirects
        'Too many redirects'
      elsif response.success?
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

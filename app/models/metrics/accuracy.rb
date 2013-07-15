require 'set'
require 'typhoeus'

module Metrics

  class Accuracy < Metric
    
    @@mime_dictionary = { 
      'csv'  => ['text/csv', 'text/x-comma-separated-values', 'text/comma-separated-values'],
      'xls'  => ['application/vnd.ms-excel', 'application/msexcel', 'application/x-msexcel',
                 'application/x-ms-excel', 'application/x-excel', 'application/x-dos_ms_excel',
                 'application/xls', 'application/x-xls'],
      'xml'  => ['application/xml'],
      'html' => ['text/html'],
      'rss'  => ['application/rss+xml'],
      'kml'  => ['application/vnd.google-earth.kml+xml'],
      'txt'  => ['text/plain']
    }

    def initialize(metadata, worker=nil)
      @worker = worker
      @processed = 0
      @requests = 0

      @resources = 0.0
      @validated_formats = 0.0
      @dispatcher = Typhoeus::Hydra.hydra

      metadata.each_with_index do |dataset, i|
        dataset[:resources].each do |resource|
          @resources += 1
          formats = determine_mime_types(resource)
          url = resource[:url]
          enqueue_request(url, formats) unless formats.nil?
        end
        @worker.at(i + i, @total) unless @worker.nil?
      end
    end

    def score
      unless @resources == 0.0
        @validated_formats / @resources
      else
        0.0
      end
    end

    def compute(dataset)
      # blocking call
      @dispatcher.run
    end

    def determine_mime_types(resource)
      format = resource[:format]
      unless format.nil?
        format = format.downcase
        if @@mime_dictionary.has_key?(format)
          return @@mime_dictionary[format]
        end
      end

      format = resource[:mimetype]
      unless format.nil?
        return [format]
      end
    end

    def enqueue_request(url, formats)
      config = {:method => :head, :timeout => 20, :connecttimeout => 10, :nosignal => true}
      request = Typhoeus::Request.new(url, config)
      request.on_complete do |response|
        content_type = response.headers['Content-Type']
        @validated_formats += 1 if formats.include?(content_type)
        @worker.at(@processed + 1, @requests)
        @processed += 1
      end
      @dispatcher.queue(request)
      @requests += 1
    end

  end

end

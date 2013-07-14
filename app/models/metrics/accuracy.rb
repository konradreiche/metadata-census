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

    def initialize
      @resources = 0.0
      @validated_formats = 0.0
      @dispatcher = Typhoeus::Hydra.hydra
    end

    def score
      unless @resources == 0.0
        @validated_formats / @resources
      else
        0.0
      end
    end

    def compute(dataset)
      dataset[:resources].each do |resource|
        @resources += 1
        url = resource[:url]
        unless resource[:format].nil?
          format = @@mime_dictionary[resource[:format].downcase]
          check(url, format)
        else
          format = [resource[:mimetype]]
          check(url, format)
        end
      end
    end

    def check(url, formats)
      config = {:method => :head, :timeout => 20, :connecttimeout => 10}
      request = Typhoeus::Request.new(url, config)
      request.on_complete do |response|
        content_type = response.headers['Content-Type']
        @validated_formats += 1 if format.include?(content_type)
      end
      @dispatcher.queue(request)
      @dispatcher.run
    end

  end

end

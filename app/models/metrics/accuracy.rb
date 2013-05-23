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

      for resource in dataset[:resources]
        @resources += 1
        unless resource[:mimetype].nil?
          format = resource[:mimetype]
        else
          if resource[:format].nil?
            return
          end
          format = resource[:format].downcase
        end

        if @@mime_dictionary.has_key?(format)
          format = @@mime_dictionary[format]
        else
          format = [format]
        end

        request = Typhoeus::Request.new(resource[:url], {:method => :head,
                                                         :timeout => 20,
                                                         :connecttimeout => 10})

        request.on_complete do |response|
          content_type = response.headers['Content-Type']
          @validated_formats += 1 if format.include?(content_type)
        end
        @dispatcher.queue(request)
        @dispatcher.run
      end

    end

  end
end

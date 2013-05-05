module Metrics

  class Accuracy
    
    @@mime_dictionary = { 
      'csv'  => ['text/csv', 'text/x-comma-separated-values', 'text/comma-separated-values'],
      'xls'  => ['application/vnd.ms-excel', 'application/msexcel', 'application/x-msexcel',
                 'application/x-ms-excel', 'application/x-excel', 'application/x-dos_ms_excel',
                 'application/xls', 'application/x-xls'],
      'xml'  => ['application/xml'],
      'html' => ['text/html'],
      'rss'  => ['application/rss+xml'],
      'kml'  => ['application/vnd.google-earth.kml+xml']
    }

    def initialize
      @resources = 0.0
      @validated_formats = 0.0
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
        AccuracyWorker.new.perform(resource[:url])
        break
      end
    end
    
  end
end

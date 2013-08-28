require 'typhoeus'

module Metrics

  class Accuracy < Metric
    
    @@mime_dictionary = { 
      'csv'   => ['text/csv', 'text/x-comma-separated-values', 'text/comma-separated-values'],
      'xls'   => ['application/vnd.ms-excel', 'application/msexcel', 'application/x-msexcel',
                  'application/x-ms-excel', 'application/x-excel', 'application/x-dos_ms_excel',
                  'application/xls', 'application/x-xls'],
      'xml'   => ['application/xml'],
      'html'  => ['text/html'],
      'rss'   => ['application/rss+xml'],
      'kml'   => ['application/vnd.google-earth.kml+xml'],
      'kmz'   => ['application/vnd.google-earth.kmz'],
      'pdf'   => ['application/pdf', 'application/x-pdf', 'application/x-bzpdf',
                  'application/x-gzpdf'],
      'txt'   => ['text/plain'],
      'zip'   => ['application/zip'],
      'axd'   => ['application/x-axd'],
      'shp'   => ['application/octet-stream'],
      'wms'   => ['application/vnd.ogc.wms_xml', 'text/xml', 'text/html',
                  'text/plain'],
      'aspx'  => ['text/html'],
      'exe'   => ['application/octet-stream', 'application/x-msdownload',
                  'application/exe', 'application/x-exe', 'application/dos-exe',
                  'vms/exe', 'application/x-winexe', 'application/msdos-windows',
                  'application/x-msdos-program'],
      'json'  => ['application/json'],
      'rtf'   => ['text/rtf', 'application/rtf'],
      'spss'  => ['application/x-spss-sav, application/x-tads-save'],
      'georss'=> ['application/rss+xml'],
      'odt'   => ['application/vnd.oasis.opendocument.text',
                  'application/x-vnd.oasis.opendocument.text'],
      'php'   => ['application/x-php'],
      'ods'   => ['application/vnd.oasis.opendocument.spreadsheet',
                  'application/x-vnd.oasis.opendocument.spreadsheet'],
      'sql'   => ['application/x-sql'],
      'sav'   => ['application/x-spss-sav, application/x-tads-save'], # see 'spss'
      'ical'  => ['text/calendar'],
      'htm'   => ['text/html'],

      # Microsoft
      'ppt'   => ['application/vnd.ms-powerpoint'],
      'xlb'   => ['application/excel', 'application/msexcel',
                  'application/vnd.ms-excel', 'application/x-excel'],

      'xlsx'  => ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
      'xltx'  => ['application/vnd.openxmlformats-officedocument.spreadsheetml.template'],
      'potx'  => ['application/vnd.openxmlformats-officedocument.presentationml.template'],
      'ppsx'  => ['application/vnd.openxmlformats-officedocument.presentationml.slideshow'],
      'pptx'  => ['application/vnd.openxmlformats-officedocument.presentationml.presentation'],
      'sldx'  => ['application/vnd.openxmlformats-officedocument.presentationml.slide'],
      'docx'  => ['application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
      'dotx'  => ['application/vnd.openxmlformats-officedocument.wordprocessingml.template'],
      'xlam'  => ['application/vnd.ms-excel.addin.macroEnabled.12'],
      'xlsb'  => ['application/vnd.ms-excel.sheet.binary.macroEnabled.12']
    }

    def initialize(metadata, worker=nil)
      @worker = worker
      @processed = 0
      @requests = 0
      @total = metadata.length

      @dispatcher = Typhoeus::Hydra.hydra
      @resource_mime_types = Hash.new { |h, k| h[k] = Hash.new }

      metadata.each_with_index do |dataset, i|
        dataset[:resources].each do |resource|
          formats = determine_mime_types(resource)
          url = URI.encode(resource[:url])
          id = dataset[:id]
          enqueue_request(id, url, formats) unless formats.nil?
        end
        @worker.at(i + i, @total) unless @worker.nil?
      end
    end

    def compute(record)
      @worker.at(@processed, @requests)

      # blocking call
      @dispatcher.run

      id = record[:id]
      types = @resource_mime_types[id]

      validated = 0.0
      resources = record[:resources].length

      record[:resources].each do |resource|
        url = resource[:url]
        mime = types[url]
        formats = determine_mime_types(resource)
        validated += 1 if formats.include?(mime)
      end

      return score, types
    end

    def score
      if resource != 0
        0.0
      else
        validated / resources
      end
    end

    def determine_mime_types(resource)
      format = resource[:format]
      unless format.nil?
        format = format.downcase.split(';').first
        if @@mime_dictionary.has_key?(format)
          return @@mime_dictionary[format]
        end
      end

      format = resource[:mimetype]
      unless format.nil?
        return [format]
      end
      []
    end

    def enqueue_request(id, url, formats)
      config = {:method => :head, :timeout => 20, :connecttimeout => 10, :nosignal => true}
      request = Typhoeus::Request.new(url, config)
      request.on_complete do |response|
        content_type = response.headers['Content-Type']
        @resource_mime_types[id][url] = content_type
        @worker.at(@processed + 1, @requests)
        @processed += 1
      end
      @dispatcher.queue(request)
      @requests += 1
    end

    def analysis
      @report
    end

  end

end

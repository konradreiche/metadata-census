require 'typhoeus'

module Metrics

  class Accuracy < Metric

    @@encoding_options = {
       :invalid           => :replace,  # Replace invalid byte sequences
       :undef             => :replace,  # Replace anything not defined in ASCII
       :replace           => '',        # Use a blank for those replacements
       :universal_newline => true       # Always break lines with \n
     }

    attr_reader :analysis

    def initialize(metadata, worker=nil)
      @worker = worker
      @mime = YAML.load('data/metrics/mime.yml')

      @processed = 0
      @requests = 0
      @total = metadata.length

      @analysis = Hash.new(0)
      @dispatcher = Typhoeus::Hydra.hydra

      @resource_mime_types = Hash.new { |h, k| h[k] = Hash.new }
      @resource_sizes = Hash.new { |h, k| h[k] = Hash.new }

      metadata.each_with_index do |dataset, i|
        dataset['resources'].each do |resource|
          formats = determine_mime_types(resource)
          url = URI.encode(resource['url'])
          id = dataset['id']
          enqueue_request(id, url, formats) unless formats.nil?
        end
        @worker.at(i + i, @total) unless @worker.nil?
      end
    end

    def run
      @dispatcher.run
    end

    def compute(record)
      @worker.at(@processed, @requests)

      # blocking call
      @dispatcher.run

      id = record['id']
      types = @resource_mime_types[id]

      max = 0 # record['resources'].length
      scores = []
      analysis = []

      record['resources'].each do |resource|
        url = resource['url']
        format = resource['format']

        actual_size = @resource_sizes[id][url].to_s
        expected_size = resource['size'].to_s

       # if not actual_size.empty? and not expected_size.empty?
       #   max += 1
       #   act, exp = actual_size.to_f, expected_size.to_f

       #   if (act - exp).abs == 0.0
       #     scores << 1.0
       #   else
       #     scores << act / (act - exp).abs
       #   end
       # end

        actual_mime_type = types[url]
        expected_mime_types = determine_mime_types(resource)

        valid = expected_mime_types.include?(actual_mime_type) 
        scores << 1.0 if valid

        analysis << { url: url,
                      format: format,
                      actual_mime_type: actual_mime_type,
                      expected_mime_types: expected_mime_types,
                      format_valid: valid,
                      actual_size: actual_size,
                      expected_size: expected_size }
      end

      if max == 0 or scores.empty?
        score = 0.0
      else
        score = scores.reduce(:+).fdiv(max)
      end

      @analysis = @analysis.to_a if @analysis.is_a?(Hash)
      return score, analysis
    end

    def determine_mime_types(resource)
      format = resource['format']

      unless format.nil?

        format = format.encode Encoding.find('ASCII'), @@encoding_options
        format = format.downcase.split(';').first
        if @mime.has_key?(format)
          return @mime[format]
        end
      end

      format = resource['mimetype']
      return [format] unless format.nil?
      return []
    end

    def enqueue_request(id, url, formats)
      config = { headers: { 'User-Agent' => 'curl/7.29.0' },
                 ssl_verifypeer: false,
                 ssl_verifyhost: 2,  # disable host verification
                 connecttimeout: 60,
                 maxredirs: 50,
                 followlocation: true,
                 method: :head,
                 nosignal: true,
                 timeout: 240 }


      request = Typhoeus::Request.new(url, config)
      request.on_complete do |response|
        content_type = response.headers['Content-Type']
        content_size = response.headers['Content-Length']
        content_type = 'Error' unless response.success?

        unless content_type.nil?
          content_type = content_type.encode Encoding.find('ASCII'), @@encoding_options
        end
        @resource_mime_types[id][url] = content_type
        @resource_sizes[id][url] = content_size
        @analysis[content_type] += 1

        @worker.at(@processed + 1, @requests) unless @worker.nil?
        @worker.eta(@processed + 1, @requests) unless @worker.nil?

        @processed += 1
      end
      @dispatcher.queue(request)
      @requests += 1
    end

    def self.description
      <<-TEXT.strip_heredoc
      The accuracy metric measures the semantic distance between the metadata
      record and the actual resource.
      TEXT
    end

  end

end

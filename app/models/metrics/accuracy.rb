require 'typhoeus'
require 'util/network'

module Metrics
  class Accuracy < Metric
    include Util::Network

    @@encoding_options = {
       :invalid           => :replace,  # Replace invalid byte sequences
       :undef             => :replace,  # Replace anything not defined in ASCII
       :replace           => '',        # Use a blank for those replacements
       :universal_newline => true       # Always break lines with \n
     }

    attr_reader :analysis

    def initialize(metadata, worker=nil)
      @worker = worker
      @mime = YAML.load(File.read('data/metrics/mime.yml'))

      @processed = 0
      @requests = 0
      @total = metadata.length

      @analysis = Hash.new(0)
      @dispatcher = Typhoeus::Hydra.hydra

      @resource_mime_types = Hash.new { |h, k| h[k] = Hash.new }
      @resource_sizes = Hash.new { |h, k| h[k] = Hash.new }

      metadata.each_with_index do |dataset, i|
        dataset['resources'].each do |resource|
          mime = resource['mimetype']
          url = URI.unescape(resource['url'])
          id = dataset['id']
          enqueue_request(id, url) unless mime.nil?
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

      max = 0
      scores = []
      analysis = []

      record['resources'].each do |resource|
        url = URI.unescape(resource['url'])
        expected_mime_type = resource['mimetype']
        next if Metrics.blank?(expected_mime_type)
        max += 1

        actual_size = @resource_sizes[id][url].to_s
        expected_size = resource['size'].to_s

        if not actual_size.empty? and not expected_size.empty?
          max += 1
          act, exp = actual_size.to_f, expected_size.to_f

          if (act - exp).abs == 0.0
            scores << 1.0
          else
            score = 1 - act.fdiv((act - exp).abs)
            score = score < 0.0 ? 0.0 : score
            scores << score
          end
        end

        actual_mime_type = @resource_mime_types[id][url]

        valid = expected_mime_type == actual_mime_type
        scores << 1.0 if valid

        analysis << { url: url,
                      actual_mime_type: actual_mime_type,
                      expected_mime_type: expected_mime_type,
                      format_valid: valid,
                      actual_size: actual_size,
                      expected_size: expected_size }
      end


      if scores.empty?
        score = 0.0
      else
        score = scores.reduce(:+).fdiv(max)
      end

      @analysis = @analysis.to_a if @analysis.is_a?(Hash)
      return score, analysis
    end

    def enqueue_request(id, url)
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

        if response.success?
          content_type = response.headers['Content-Type'].to_s.split(';').first
          content_size = response.headers['Content-Length']
        else
          content_type = response_message(response)
        end

        # content_type = content_type.encode(Encoding.find('ASCII'), @@encoding_options)

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

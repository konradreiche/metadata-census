require 'yajl'
require 'yajl/gzip'

class Admin::SnapshotsController < ApplicationController
  include Concerns::Repository

  before_filter :init

  def init
    load_repositories(:repository_id)
  end

  def create
    file = params[:file]
    snapshot = nil

    File.open(file) do |file|
      parse_metadata(file) do |parsed|

        case parsed
        when Hash
          attributes = filter_header(parsed)
          snapshot = Snapshot.create!(attributes)
        when Array
          parsed.each do |metadata|
            metadata = Metadata.create!(record: metadata)
            snapshot.records << metadata
          end
        else
          raise TypeError, "Unknown type #{parsed.class}"
        end

      end
    end

    render nothing: true
  end

  def parse_metadata(file)
    gz = Zlib::GzipReader.new(file)
    parser = Yajl::Parser.new(symbolize_keys: true)
    parser.on_parse_complete = Proc.new { |obj| yield(obj) }
    parser << gz.read
  end

  def filter_header(header)
    fields = Snapshot.fields.keys.map(&:to_sym)
    header.keys.inject({}) do |filtered, key|
      filtered[key] = header[key] if fields.include?(key)
      filtered
    end
  end

end

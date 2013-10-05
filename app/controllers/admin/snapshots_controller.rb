require 'digest'
require 'yajl'
require 'yajl/gzip'

class Admin::SnapshotsController < ApplicationController
  include RepositoryManager

  def create
    file = params[:file]
    snapshot = nil

    File.open(file) do |file|
      parse_metadata(file) do |parsed|

        case parsed
        when Hash
          attributes = filter_header(parsed)
          repository = Repository.find(parsed['repository'].downcase)
          snapshot = repository.snapshots.where(date: attributes['date'])

          if not snapshot.exists?
            snapshot = repository.snapshots.create!(attributes)
          else
            snapshot = snapshot.first
            snapshot.update_attributes!(attributes)
          end

        when Array
          records = parsed.map do |metadata|
            id = Digest::MD5.hexdigest(metadata["id"] + snapshot.id)
            attributes = { _id: id, record: metadata,
                           snapshot_id: snapshot.id,
                           statistics: { resources: metadata['resources'].length } }
          end
          records.each_slice(4000).each do |records|
            MetadataRecord.collection.insert(records)
          end
        else
          raise TypeError, "Unknown type #{parsed.class}"
        end

      end
      snapshot.save!
    end

    render nothing: true
  end

  def destroy
    require 'pry'; binding.pry
    @snapshot.delete
    render nothing: true
  end

  def parse_metadata(file)
    gz = Zlib::GzipReader.new(file)
    parser = Yajl::Parser.new
    parser.on_parse_complete = Proc.new { |obj| yield(obj) }
    while not gz.eof?
      parser << gz.readline
    end
  end

  def filter_header(header)
    fields = Snapshot.fields.keys
    header.keys.inject({}) do |filtered, key|
      filtered[key] = header[key] if fields.include?(key)
      filtered
    end
  end

end

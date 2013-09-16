require 'json/stream'
require 'yajl'

class Admin::RepositoriesController < ApplicationController
  helper_method :repository_count

  def create
    file = params[:file]
    catalog = YAML.load_file(file).with_indifferent_access

    repositories = catalog[:repositories].each do |repository|
      location = Geocoder.search(repository[:location]).first
      repository[:latitude] = location.latitude
      repository[:longitude] = location.longitude

      entity = Repository.find(repository[:id])
      entity = Repository.new if entity.nil?
      entity.update(repository)
    end

    render nothing: true
  end

  def new
    @repository_files = repository_files()
    @metadata_archives = metadata_archives()
  end

  def repository_files
    files = Dir.glob('data/repositories/*.yml').select { |f| File.file?(f) }
    files.map do |yaml| 
      { yaml => YAML.load_file(yaml).with_indifferent_access }
    end.reduce(:merge)
  end

  ##
  # Returns a list of available metadata archives.
  #
  def metadata_archives
    options = { symbolize_keys: true }
    archives = Dir.glob('data/archives/**/*').select { |f| File.file?(f) }

    archives.inject({}) do |result, archive|
      result[archive] = parse_meta_metadata(archive)
      result
    end
  end

  ##
  # Parses the meta-metadata from the archive in a stream-based fashion.
  #
  def parse_meta_metadata(file)
    result = {}
    keys = [:id, :date, :count]

    pick_next = false
    pick_key = nil

    parser = JSON::Stream::Parser.new do
      value { |value| result[pick_key] = value if pick_next }

      key do |key|
        pick_next = keys.include?(key.to_sym) 
        pick_key = key.to_sym
      end
    end

    File.open(file, 'r') do |file|
      file.each_char do |char|
        parser << char
        break if result.keys.sort == keys.sort
      end
    end

    result
  end

  def repository_count(yaml)
    yaml.except(:name).values.map(&:length).reduce(:+)
  end
    
end

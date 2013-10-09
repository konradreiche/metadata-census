require 'yajl'
require 'yajl/gzip'

class Admin::RepositoriesController < ApplicationController
  include RepositoryManager
  include MetricManager

  helper_method :repository_count

  def create
    file = params[:file]
    catalog = YAML.load_file(file).with_indifferent_access

    repositories = catalog[:repositories].each do |repository|
      attributes = attribute_hash(repository)
      repository = Repository.where(_id: attributes[:_id])

      if not repository.exists?
        repository = Repository.create!(attributes)
      else
        repository.first.update_attributes!(attributes)
      end
    end

    render nothing: true
  end

  def new
    @repository_files = repository_files()
    @metadata_archives = metadata_archives()
  end

  def compile
   controller = Admin::SnapshotsController.new

   if params[:target] == 'languages'
     Repository.all.each do |repository|
       repository.snapshots.each do |snapshot|
         logger.info("Compiling #{repository.name}")
         controller.compile_languages(snapshot)
         snapshot.save!
       end
     end
   elsif params[:target] == 'times'
     Repository.all.each do |repository|
       repository.snapshots.each do |snapshot|
         logger.info("Compiling #{repository.name}")
         controller.compile_times(snapshot)
         snapshot.save!
       end
     end
   else
     Repository.all.each do |repository|
       repository.snapshots.each do |snapshot|
         logger.info("Compiling #{repository.name}")
         controller.compile_statistics(snapshot)
         snapshot.save!
       end
     end
   end
 
   render nothing: true
 end

 ##
  # Returns a list of available YAML files containing repositories to import.
  #
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

    result = Hash.new { |hash, key| hash[key] = [] }
    archives.inject(result) do |result, archive|
      header = parse_header(archive)
      header[:file] = archive
      result[header[:repository]] << header
      result
    end
  end

  ##
  # Parses the meta-metadata from the archive in a stream-based fashion.
  #
  def parse_header(file)
    reader = Yajl::Gzip::StreamReader.new(File.new(file, 'r'))
    parser = Yajl::Parser.new(symbolize_keys: true)

    parser.on_parse_complete = Proc.new { |obj| return obj }
    loop { parser << reader.readchar }
  rescue Zlib::GzipFile::Error
    logger.error("Invalid file format: unexpected end of file for #{file}")
  end

  def scheduler
  end

  def repository_count(yaml)
    yaml.except(:name).values.map(&:length).reduce(:+)
  end

  private

  ##
  # Returns hash of valid attributes which can be used to create a new
  # +Repository+ object.
  #
  def attribute_hash(repository_hash)
    city = repository_hash[:location]
    location = Geocoder.search(city).first
    id = repository_hash.delete('id')

    raise TypeError, 'Repository identifier must not be null' if id.nil?

    repository_hash[:_id] = id
    repository_hash[:latitude] = location.latitude
    repository_hash[:longitude] = location.longitude
    repository_hash.delete_if do |attribute, value|
      not Repository.fields.include?(attribute)
    end
  end
    
end

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
      attributes = attribute_hash(repository).with_indifferent_access
      repository = Repository.where(id: repository[:id])

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

  def status
    repository = @repository.id
    jobs = Job.where(repository: repository)
  
    status = jobs.to_a.inject({}) do |status, job|
      status[job.metric] = Sidekiq::Status::get_all(job.sidekiq_id)
      percent = Sidekiq::Status::pct_complete(job.sidekiq_id)
      status[job.metric][:percent] = percent.finite? ? percent : 0.0
      status
    end

    render json: status
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
    domain = domain(repository_hash[:url])

    repository_hash[:domain] = domain
    repository_hash[:latitude] = location.latitude
    repository_hash[:longitude] = location.longitude
    repository_hash.delete_if do |attribute, value|
      not Repository.fields.include?(attribute)
    end
  end

  def domain(url)
    url.split(/(http:|https:)/).last[2..-1].split('/')[0].sub('www.', '')
  end
    
end

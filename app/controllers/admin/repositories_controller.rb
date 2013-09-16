class Admin::RepositoriesController < ApplicationController
  helper_method :repository_count

  def create
    file = params[:file]
    catalog = YAML.load_file(file).with_indifferent_access

    repositories = catalog[:repositories].map do |repository|
      location = repository.delete(:location)
      location = Geocoder.search(location).first

      repository[:latitude] = location.latitude
      repository[:longitude] = location.longitude

      repository.delete(:dump)
      repository.delete(:rows)
      Repository.new(repository)
    end
    repositories.each { |repository| repository.index.store(repository) }

    render nothing: true
  end

  def new
    @repository_files = repository_files
  end

  def repository_files
    files = Dir.glob('data/repositories/*.yml').select { |f| File.file?(f) }
    files.map do |yaml| 
      { yaml => YAML.load_file(yaml).with_indifferent_access }
    end.reduce(:merge)
  end

  def repository_count(yaml)
    yaml.except(:name).values.map(&:length).reduce(:+)
  end
    
end
